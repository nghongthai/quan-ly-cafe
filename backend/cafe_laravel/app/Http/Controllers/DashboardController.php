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
     * 2. Xử lý bộ lọc dữ liệu thực tế cho RevenueReportScreen (Đã nâng cấp đào sâu xem từng ngày trong tuần con)
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
                    ->map(function ($item) {
                        return [
                            'time' => sprintf("%02d:00 - %02d:00", $item->hour, $item->hour + 1),
                            'revenue' => (double) $item->revenue,
                            'orders' => (int) $item->orders,
                        ];
                    });

            } else if ($type == 'tuần') {
                $startOfWeek = Carbon::now('Asia/Ho_Chi_Minh')->startOfWeek();
                $endOfWeek = Carbon::now('Asia/Ho_Chi_Minh')->endOfWeek();

                $totalRevenue = (double) (clone $baseQuery)->whereBetween('created_at', [$startOfWeek, $endOfWeek])->sum('total_amount');
                $totalOrders = (int) (clone $baseQuery)->whereBetween('created_at', [$startOfWeek, $endOfWeek])->count();

                $daysData = Order::select(
                        DB::raw('DAYNAME(created_at) as day_name'),
                        DB::raw('DAYOFWEEK(created_at) as day_code'),
                        DB::raw('SUM(total_amount) as revenue'),
                        DB::raw('COUNT(*) as orders')
                    )
                    ->where('status', 'completed')
                    ->whereBetween('created_at', [$startOfWeek, $endOfWeek])
                    ->groupBy('day_name', 'day_code')
                    ->orderBy('day_code', 'asc')
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
                    ];
                });

            } else {
                // 🔥 ĐÃ CẬP NHẬT: Xử lý hiển thị doanh thu TỪNG NGÀY của một TUẦN con cụ thể khi chọn bộ lọc THÁNG
                preg_match('/(\d+)/', $subWeek, $matches);
                $weekNum = isset($matches[1]) ? (int)$matches[1] : 1; // Tách lấy số tuần: 1, 2, 3, 4

                // Định vị ngày bắt đầu và kết thúc của tuần con trong tháng hiện hành
                $weekStart = Carbon::now('Asia/Ho_Chi_Minh')->startOfMonth()->addWeeks($weekNum - 1)->startOfDay();
                $weekEnd = ($weekNum == 4) 
                    ? Carbon::now('Asia/Ho_Chi_Minh')->endOfMonth()->endOfDay() 
                    : Carbon::now('Asia/Ho_Chi_Minh')->startOfMonth()->addWeeks($weekNum)->subSecond()->endOfDay();

                // Tính tổng doanh thu & đơn hàng của riêng tuần con được click để hiển thị lên thẻ Card lớn phía trên
                $totalRevenue = (double) (clone $baseQuery)->whereBetween('created_at', [$weekStart, $weekEnd])->sum('total_amount');
                $totalOrders = (int) (clone $baseQuery)->whereBetween('created_at', [$weekStart, $weekEnd])->count();

                $vietnameseDays = [
                    'Monday' => 'Thứ Hai', 'Tuesday' => 'Thứ Ba', 'Wednesday' => 'Thứ Tư',
                    'Thursday' => 'Thứ Năm', 'Friday' => 'Thứ Sáu', 'Saturday' => 'Thứ Bảy', 'Sunday' => 'Chủ Nhật'
                ];

                // Chạy vòng lặp duyệt qua từng ngày từ ngày đầu tuần tới ngày cuối tuần
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

                    // Đẩy dữ liệu thống kê của ngày này vào danh sách chi tiết bên dưới
                    $details[] = [
                        'time' => $dayName . " (" . $currentDay->format('d/m') . ")",
                        'revenue' => $dayRevenue,
                        'orders' => $dayOrders
                    ];

                    $currentDay->addDay(); // Tiến sang ngày kế tiếp
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
     * 3. API MỚI: Xử lý hiển thị toàn bộ hiệu suất sản phẩm (Lọc theo Ngày/Tuần/Tháng)
     */
    public function getDetailedProductPerformance(Request $request)
    {
        try {
            $type = strtolower($request->query('type', 'ngày'));
            $now = Carbon::now('Asia/Ho_Chi_Minh');
            
            $query = Order::where('status', 'completed');
            
            // Xử lý logic lọc thời gian
            if ($type == 'ngày') {
                $query->whereDate('created_at', $now->format('Y-m-d'));
            } else if ($type == 'tuần') {
                $query->whereBetween('created_at', [$now->copy()->startOfWeek(), $now->copy()->endOfWeek()]);
            } else { 
                $query->whereMonth('created_at', $now->month)
                      ->whereYear('created_at', $now->year);
            }

            // Lấy danh sách ID của các đơn hàng hợp lệ
            $orderIds = $query->pluck('id');

            // Tính tổng số lượng bán ra của tất cả các sản phẩm có trong các đơn hàng trên
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
}