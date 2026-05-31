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
     * 2. Xử lý bộ lọc dữ liệu thực tế cho RevenueReportScreen (Tách biệt logic hoàn toàn)
     */
    public function getRevenueReport(Request $request)
    {
        try {
            $type = $request->query('type', 'ngày');
            $details = [];

            // Thiết lập múi giờ Việt Nam để tính toán chính xác thời gian đơn hàng
            Carbon::setLocale('vi');
            $now = Carbon::now('Asia/Ho_Chi_Minh');

            // Khởi tạo Base Query gốc cho các đơn hàng đã hoàn thành
            $baseQuery = Order::where('status', 'completed');

            if ($type == 'ngày') {
                $today = Carbon::now('Asia/Ho_Chi_Minh')->format('Y-m-d');

                // Sử dụng clone để cô lập truy vấn tính tổng cho riêng ngày hôm nay ☀️
                $totalRevenue = (double) (clone $baseQuery)->whereDate('created_at', $today)->sum('total_amount');
                $totalOrders = (int) (clone $baseQuery)->whereDate('created_at', $today)->count();

                // Lấy chi tiết biến động doanh thu theo từng khung giờ trong ngày hôm nay
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
                // Xác định mốc thời gian đầu tuần và cuối tuần hiện tại 📅
                $startOfWeek = Carbon::now('Asia/Ho_Chi_Minh')->startOfWeek();
                $endOfWeek = Carbon::now('Asia/Ho_Chi_Minh')->endOfWeek();

                $totalRevenue = (double) (clone $baseQuery)->whereBetween('created_at', [$startOfWeek, $endOfWeek])->sum('total_amount');
                $totalOrders = (int) (clone $baseQuery)->whereBetween('created_at', [$startOfWeek, $endOfWeek])->count();

                // Lấy chi tiết doanh thu theo từng ngày trong tuần
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
                // Mặc định hoặc khi chọn chế độ lọc theo Tháng 🌕
                $startOfMonth = Carbon::now('Asia/Ho_Chi_Minh')->startOfMonth();
                $endOfMonth = Carbon::now('Asia/Ho_Chi_Minh')->endOfMonth();

                $totalRevenue = (double) (clone $baseQuery)->whereBetween('created_at', [$startOfMonth, $endOfMonth])->sum('total_amount');
                $totalOrders = (int) (clone $baseQuery)->whereBetween('created_at', [$startOfMonth, $endOfMonth])->count();

                // Chia nhỏ doanh thu theo từng mốc tuần con trong tháng
                for ($i = 1; $i <= 4; $i++) {
                    $weekStart = Carbon::now('Asia/Ho_Chi_Minh')->startOfMonth()->addWeeks($i - 1);
                    $weekEnd = ($i == 4) ? Carbon::now('Asia/Ho_Chi_Minh')->endOfMonth() : Carbon::now('Asia/Ho_Chi_Minh')->startOfMonth()->addWeeks($i)->subSecond();

                    $weekRevenue = (double) (clone $baseQuery)->whereBetween('created_at', [$weekStart, $weekEnd])->sum('total_amount');
                    $weekOrders = (int) (clone $baseQuery)->whereBetween('created_at', [$weekStart, $weekEnd])->count();

                    $details[] = [
                        'time' => "Tuần $i (Từ " . $weekStart->format('d/m') . " đến " . $weekEnd->format('d/m') . ")",
                        'revenue' => $weekRevenue,
                        'orders' => $weekOrders
                    ];
                }
            }

            // Trả về cấu trúc JSON chuẩn hóa khớp hoàn toàn với cấu trúc Flutter mong đợi
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
}