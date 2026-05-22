<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Table;
use App\Models\OrderDetail;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function getStats()
    {
        try {
            // 1. Doanh thu: Tổng số tiền của TẤT CẢ các đơn hàng đã hoàn thành (Bỏ lọc ngày)
            $revenue = Order::where('status', 'completed')
                ->sum('total_amount');

            // 2. Tổng số đơn hàng thành công từ trước tới nay (Bỏ lọc ngày)
            $ordersCount = Order::where('status', 'completed')
                ->count();

            // 3. Số bàn đang có khách (Giữ nguyên logic đếm số bàn hiện tại)
            $activeTables = Table::where(function($query) {
                $query->where('status', 'occupied')
                      ->orWhere('status', '1')
                      ->orWhere('status', 1);
            })->count();

            // 4. Top 3 sản phẩm bán chạy nhất toàn thời gian (Bỏ use $today và bỏ lọc ngày ở đây)
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

            // Trả về JSON sạch sẽ để Flutter hiển thị dữ liệu
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
}