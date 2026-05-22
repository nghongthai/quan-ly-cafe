<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\Table;
use App\Models\Product;
use App\Models\OrderDetail;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    // 1. Lấy danh sách món ăn cho Menu
    public function getProducts()
    {
        $products = Product::all(); // Lấy tất cả để tránh thiếu món trên Flutter
        return response()->json($products);
    }

    // 2. Lấy đơn hàng hiện tại của 1 bàn
    public function getOrderByTable($tableId)
    {
        $order = Order::with(['table', 'orderDetails.product'])
                      ->where('table_id', $tableId)
                      ->where('status', 'pending')
                      ->first();

        if (!$order) {
            return response()->json([
                'success' => false, 
                'message' => 'Bàn này hiện đang trống',
                'data' => null
            ]);
        }

        return response()->json([
            'success' => true, 
            'data' => $order
        ]);
    }

    // 3. Thêm món mới từ Menu
    public function addProduct(Request $request)
    {
        $request->validate([
            'table_id' => 'required|exists:tables,id',
            'product_id' => 'required|exists:products,id',
            'quantity' => 'nullable|integer|min:1'
        ]);

        return DB::transaction(function () use ($request) {
            $order = Order::firstOrCreate(
                ['table_id' => $request->table_id, 'status' => 'pending'],
                ['total_amount' => 0]
            );

            // Cập nhật trạng thái bàn sang "Sử dụng" (1)
            Table::where('id', $request->table_id)->update(['status' => 1]);

            $product = Product::findOrFail($request->product_id);
            $qty = $request->quantity ?? 1;

            $detail = OrderDetail::where('order_id', $order->id)
                                ->where('product_id', $product->id)->first();

            if ($detail) {
                $detail->increment('quantity', $qty);
            } else {
                OrderDetail::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'quantity' => $qty,
                    'price' => $product->price,
                ]);
            }

            $this->updateTotalAmount($order);
            return response()->json(['success' => true, 'message' => 'Đã thêm món']);
        });
    }

    // 4. Cập nhật số lượng (Cộng, Trừ, Xóa)
    public function updateOrderDetail(Request $request)
    {
        $request->validate([
            'table_id' => 'required',
            'product_id' => 'required',
            'action' => 'required|in:increment,decrement,delete'
        ]);

        return DB::transaction(function () use ($request) {
            $order = Order::where('table_id', $request->table_id)
                          ->where('status', 'pending')
                          ->first();

            if (!$order) {
                return response()->json(['success' => false, 'message' => 'Không tìm thấy đơn'], 404);
            }

            $detail = OrderDetail::where('order_id', $order->id)
                                ->where('product_id', $request->product_id)
                                ->first();

            if ($detail) {
                if ($request->action == 'increment') {
                    $detail->increment('quantity');
                } 
                elseif ($request->action == 'decrement') {
                    if ($detail->quantity > 1) {
                        $detail->decrement('quantity');
                    } else {
                        $detail->delete();
                    }
                } 
                elseif ($request->action == 'delete') {
                    $detail->delete();
                }

                if ($order->orderDetails()->count() == 0) {
                    $order->delete();
                    Table::where('id', $request->table_id)->update(['status' => 0]);
                    return response()->json(['success' => true, 'message' => 'Bàn trống', 'data' => null]);
                }

                $this->updateTotalAmount($order);
            }

            return response()->json(['success' => true, 'message' => 'Cập nhật thành công']);
        });
    }

    // 5. Thanh toán (PHẦN QUAN TRỌNG NHẤT)
    public function checkout(Request $request)
    {
        $request->validate(['table_id' => 'required|exists:tables,id']);

        return DB::transaction(function () use ($request) {
            $order = Order::where('table_id', $request->table_id)
                          ->where('status', 'pending')->first();

            if ($order) {
                // SỬA TẠI ĐÂY: Cập nhật status kèm theo thời gian hiện tại
                // Để DashboardController dùng whereDate('updated_at', ...) tính được tiền
                $order->update([
                    'status' => 'completed',
                    'updated_at' => now() 
                ]);

                // Trả bàn về trạng thái trống (0)
                Table::where('id', $request->table_id)->update(['status' => 0]);

                return response()->json(['success' => true, 'message' => 'Thanh toán hoàn tất']);
            }
            return response()->json(['success' => false, 'message' => 'Không tìm thấy đơn'], 404);
        });
    }

    // 6. Lọc danh sách đơn hàng
    public function listOrders(Request $request)
    {
        $status = $request->input('status');
        $filter = $request->input('filter'); 
        
        $query = Order::with(['table', 'orderDetails.product']);

        if ($request->filled('status') && $status !== 'all') {
            $query->where('status', $status);
        }

        if ($request->filled('filter')) {
            if ($filter == 'today') {
                $query->whereDate('updated_at', date('Y-m-d')); 
            } elseif ($filter == 'week') {
                $query->whereBetween('updated_at', [
                    now()->startOfWeek(), 
                    now()->endOfWeek()
                ]); 
            }
        }

        $orders = $query->orderBy('updated_at', 'desc')->get();

        return response()->json([
            'success' => true, 
            'data' => $orders
        ]);
    }

    // 7. Hàm tính lại tiền
    private function updateTotalAmount($order)
    {
        $total = $order->orderDetails()->sum(DB::raw('quantity * price'));
        $order->update(['total_amount' => $total]);
    }
}