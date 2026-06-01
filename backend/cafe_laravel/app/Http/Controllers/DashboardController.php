<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Table;
use App\Models\OrderDetail;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardController extends Controller
{
    /**
     * 1. Lấy thông tin tổng quan hiển thị ở trang chủ Admin
     */
    public function getStats()
    {
        try {
            // Doanh thu: Tổng số tiền của TẤT CẢ các đơn hàng đã hoàn thành
            $revenue = Order::where('status', 'completed')
                ->sum('total_amount');

            // Tổng số đơn hàng thành công từ trước tới nay
            $ordersCount = Order::where('status', 'completed')
                ->count();

            // Số bàn đang có khách 
            $activeTables = Table::where(function($query) {
                $query->where('status', 'occupied')
                      ->orWhere('status', '1')
                      ->orWhere('status', 1);
            })->count();

            // Top 3 sản phẩm bán chạy nhất toàn thời gian
            $topProducts = OrderDetail::select('product_id', DB::raw('SUM(quantity) as sold'))
                ->whereHas('order', function($q) {
                    $q->where('status', 'completed');
                })
                ->with('product')
                ->groupBy('product_id')
                ->orderBy('sold', 'desc')
                ->take(3)
                ->get()
                ->map(function($item) {
                    return [
                        'name' => $item->product->name ?? 'Sản phẩm',
                        'sold' => (int)$item->sold,
                        'image' => $item->product->image ?? 'cafe_den.png',
                    ];
                });

            return response()->json([
                'revenue' => (double)$revenue,
                'orders_count' => (int)$ordersCount,
                'active_tables' => (int)$activeTables,
                'growth_rate' => 0,
                'top_products' => $topProducts
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ], 500);
        }
    }

    /**
     * 2. Xử lý bộ lọc dữ liệu thực tế cho RevenueReportScreen (Đã bổ sung trường 'date' cho mọi bộ lọc)
     */
    public function getRevenueReport(Request $request)
    {
        try {
            $type = $request->query('type', 'ngày');
            $subWeek = $request->query('sub_week', 'Tuần 1'); // Hứng tham số tuần con truyền từ Flutter lên
            $details = [];

            // Thiết lập múi giờ Việt Nam
            Carbon::setLocale('vi');
            
            // Khởi tạo Base Query gốc cho các đơn hàng đã hoàn thành
            $baseQuery = Order::where('status', 'completed');

            if ($type == 'ngày') {
                $today = Carbon::now('Asia/Ho_Chi_Minh')->format('Y-m-d');

                $totalRevenue = (double) (clone $baseQuery)->whereDate('created_at', $today)->sum('total_amount');
                $totalOrders = (int) (clone $baseQuery)->whereDate('created_at', $today)->count();

                $details = Order::select(
                        DB::raw('HOUR(created_at) as hour'),
                        DB::raw('SUM(total_amount) as revenue'),
                        DB::raw('COUNT(*) as orders')
                    )
                    ->where('status', 'completed')
                    ->whereDate('created_at', $today)
                    ->groupBy('hour')
                    ->orderBy('hour', 'asc')
                    ->get()
                    ->map(function ($item) use ($today) {
                        return [
                            'time' => sprintf("%02d:00 - %02d:00", $item->hour, $item->hour + 1),
                            'revenue' => (double) $item->revenue,
                            'orders' => (int) $item->orders,
                            'date' => $today, // 🌟 Gài ngày hôm nay để khi bấm vào khung giờ vẫn bốc trọn đơn trong ngày
                        ];
                    });

            } else if ($type == 'tuần') {
                $startOfWeek = Carbon::now('Asia/Ho_Chi_Minh')->startOfWeek();
                $endOfWeek = Carbon::now('Asia/Ho_Chi_Minh')->endOfWeek();

                $totalRevenue = (double) (clone $baseQuery)->whereBetween('created_at', [$startOfWeek, $endOfWeek])->sum('total_amount');
                $totalOrders = (int) (clone $baseQuery)->whereBetween('created_at', [$startOfWeek, $endOfWeek])->count();

                $daysData = Order::select(
                        DB::raw('DATE(created_at) as order_date'), // 🌟 Bổ sung bốc ngày thực tế
                        DB::raw('DAYNAME(created_at) as day_name'),
                        DB::raw('DAYOFWEEK(created_at) as day_code'),
                        DB::raw('SUM(total_amount) as revenue'),
                        DB::raw('COUNT(*) as orders')
                    )
                    ->where('status', 'completed')
                    ->whereBetween('created_at', [$startOfWeek, $endOfWeek])
                    ->groupBy('order_date', 'day_name', 'day_code')
                    ->orderBy('order_date', 'asc')
                    ->get();

                $vietnameseDays = [
                    'Monday' => 'Thứ Hai', 'Tuesday' => 'Thứ Ba', 'Wednesday' => 'Thứ Tư',
                    'Thursday' => 'Thứ Năm', 'Friday' => 'Thứ Sáu', 'Saturday' => 'Thứ Bảy', 'Sunday' => 'Chủ Nhật'
                ];

                $details = $daysData->map(function ($item) use ($vietnameseDays) {
                    return [
                        'time' => $vietnameseDays[$item->day_name] ?? $item->day_name,
                        'revenue' => (double) $item->revenue,
                        'orders' => (int) $item->orders,
                        'date' => $item->order_date, // 🌟 Trả về ngày yyyy-MM-dd chính xác của Thứ đó
                    ];
                });

            } else {
                // Xử lý hiển thị doanh thu TỪNG NGÀY của một TUẦN con cụ thể khi chọn bộ lọc THÁNG
                preg_match('/(\d+)/', $subWeek, $matches);
                $weekNum = isset($matches[1]) ? (int)$matches[1] : 1; 

                // Định vị ngày bắt đầu và kết thúc của tuần con trong tháng hiện hành
                $weekStart = Carbon::now('Asia/Ho_Chi_Minh')->startOfMonth()->addWeeks($weekNum - 1)->startOfDay();
                $weekEnd = ($weekNum == 4) 
                    ? Carbon::now('Asia/Ho_Chi_Minh')->endOfMonth()->endOfDay() 
                    : Carbon::now('Asia/Ho_Chi_Minh')->startOfMonth()->addWeeks($weekNum)->subSecond()->endOfDay();

                $totalRevenue = (double) (clone $baseQuery)->whereBetween('created_at', [$weekStart, $weekEnd])->sum('total_amount');
                $totalOrders = (int) (clone $baseQuery)->whereBetween('created_at', [$weekStart, $weekEnd])->count();

                $vietnameseDays = [
                    'Monday' => 'Thứ Hai', 'Tuesday' => 'Thứ Ba', 'Wednesday' => 'Thứ Tư',
                    'Thursday' => 'Thứ Năm', 'Friday' => 'Thứ Sáu', 'Saturday' => 'Thứ Bảy', 'Sunday' => 'Chủ Nhật'
                ];

                $currentDay = $weekStart->copy();
                while ($currentDay->lte($weekEnd)) {
                    $dayStr = $currentDay->format('Y-m-d');
                    $dayName = $vietnameseDays[$currentDay->format('l')] ?? $currentDay->format('l');

                    $dayRevenue = (double) Order::where('status', 'completed')
                        ->whereDate('created_at', $dayStr)
                        ->sum('total_amount');
                        
                    $dayOrders = (int) Order::where('status', 'completed')
                        ->whereDate('created_at', $dayStr)
                        ->count();

                    $details[] = [
                        'time' => $dayName . " (" . $currentDay->format('d/m') . ")",
                        'revenue' => $dayRevenue,
                        'orders' => $dayOrders,
                        'date' => $dayStr // 🌟 Trả về ngày yyyy-MM-dd chính xác trong tháng
                    ];

                    $currentDay->addDay(); 
                }
            }

            return response()->json([
                'total_revenue' => $totalRevenue,
                'total_orders' => $totalOrders,
                'details' => $details
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ], 500);
        }
    }

    /**
     * 3. Lọc hiệu suất sản phẩm (Lọc theo Ngày/Tuần/Tháng)
     */
    public function getDetailedProductPerformance(Request $request)
    {
        try {
            $type = strtolower($request->query('type', 'ngày'));
            $now = Carbon::now('Asia/Ho_Chi_Minh');
            
            $query = Order::where('status', 'completed');
            
            if ($type == 'ngày') {
                $query->whereDate('created_at', $now->format('Y-m-d'));
            } else if ($type == 'tuần') {
                $query->whereBetween('created_at', [$now->copy()->startOfWeek(), $now->copy()->endOfWeek()]);
            } else { 
                $query->whereMonth('created_at', $now->month)
                      ->whereYear('created_at', $now->year);
            }

            $orderIds = $query->pluck('id');

            $products = OrderDetail::select('product_id', DB::raw('SUM(quantity) as sold'))
                ->whereIn('order_id', $orderIds)
                ->with('product') 
                ->groupBy('product_id')
                ->orderBy('sold', 'desc')
                ->get()
                ->map(function ($item) {
                    return [
                        'name' => $item->product->name ?? 'Sản phẩm',
                        'sold' => (int) $item->sold,
                        'image' => $item->product->image ?? 'cafe_den.png',
                    ];
                });

            return response()->json([
                'filter' => $type,
                'data' => $products
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    /**
     * 4. API MỚI BỔ SUNG: Lấy toàn bộ danh sách đơn hàng đã hoàn thành của một Ngày cụ thể
     * Đường dẫn gọi: /api/dashboard/orders-by-date?date=YYYY-MM-DD
     */
    public function getOrdersByDate(Request $request)
    {
        try {
            $date = $request->query('date');

            if (!$date) {
                return response()->json(['error' => 'Thiếu thông tin ngày lọc dữ liệu'], 400);
            }

            // Lấy tất cả đơn hàng đã hoàn thành trong ngày được chọn
            $orders = Order::with(['table', 'orderDetails.product'])
                ->whereDate('created_at', $date)
                ->where('status', 'completed')
                ->orderBy('updated_at', 'desc') // Đơn mới làm xong đẩy lên đầu
                ->get();

            return response()->json($orders, 200);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    /**
     * 🌟 5. API MỚI BỔ SUNG: Lấy báo cáo tổng kết cuối ngày tinh gọn
     * (Chỉ gồm khối Phương thức thanh toán & Tổng kết bán hàng theo đúng yêu cầu)
     * Đường dẫn gọi: /api/dashboard/end-of-day-report
     */
    /**
     * 🌟 API Lấy báo cáo tổng kết cuối ngày (Bản nâng cấp chống lệch múi giờ hệ thống)
     */
    public function getEndOfDayReport()
    {
        try {
            // Dùng cặp thời gian đầu ngày và cuối ngày chuẩn múi giờ Việt Nam để quét sạch đơn
            $startOfDay = Carbon::now('Asia/Ho_Chi_Minh')->startOfDay();
            $endOfDay = Carbon::now('Asia/Ho_Chi_Minh')->endOfDay();

            // Lọc chính xác các đơn hoàn thành trong khung giờ ngày hôm nay
            $todayOrders = Order::whereBetween('created_at', [$startOfDay, $endOfDay])
                                ->where('status', 'completed')
                                ->get();

            $totalOrders = $todayOrders->count();
            
            // Tính toán gom nhóm dòng tiền từ Collection
            $tienMat = (double) $todayOrders->where('payment_method', 'Tiền mặt')->sum('total_amount');
            $chuyenKhoan = (double) $todayOrders->where('payment_method', 'Chuyển khoản')->sum('total_amount');
            $tongThu = $tienMat + $chuyenKhoan;

            // Tính tổng số món nước bán ra
            $orderIds = $todayOrders->pluck('id');
            $tongSanPham = (int) OrderDetail::whereIn('order_id', $orderIds)->sum('quantity');

            return response()->json([
                'tien_mat' => $tienMat,
                'chuyen_khoan' => $chuyenKhoan,
                'the' => 0,
                'vi_dien_tu' => 0,
                'diem' => 0,
                'so_luong_hoa_don' => $totalOrders,
                'so_luong_san_pham' => $tongSanPham,
                'so_khach' => $totalOrders, 
                'doanh_thu_uoc_tinh' => $tongThu
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}