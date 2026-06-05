<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderDetail;
use App\Models\Product;
use App\Models\Table;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class OrderController extends Controller
{
    public function getProducts()
    {
        return response()->json(Product::all());
    }

    public function getOrderByTable($tableId)
    {
        $order = Order::with(['table', 'orderDetails.product'])
            ->where('table_id', $tableId)
            ->where('status', 'pending')
            ->first();

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Ban nay hien dang trong',
                'data' => null,
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $order,
        ]);
    }

    public function addProduct(Request $request)
    {
        $request->validate([
            'table_id' => 'required|exists:tables,id',
            'product_id' => 'required|exists:products,id',
            'quantity' => 'nullable|integer|min:1',
        ]);

        return DB::transaction(function () use ($request) {
            $order = Order::firstOrCreate(
                ['table_id' => $request->table_id, 'status' => 'pending'],
                ['total_amount' => 0]
            );

            Table::where('id', $request->table_id)->update(['status' => 1]);

            $product = Product::findOrFail($request->product_id);
            $quantity = $request->quantity ?? 1;

            $detail = OrderDetail::where('order_id', $order->id)
                ->where('product_id', $product->id)
                ->first();

            if ($detail) {
                $detail->increment('quantity', $quantity);
            } else {
                OrderDetail::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'quantity' => $quantity,
                    'price' => $product->price,
                ]);
            }

            $this->updateTotalAmount($order);

            return response()->json(['success' => true, 'message' => 'Da them mon']);
        });
    }

    public function updateOrderDetail(Request $request)
    {
        $request->validate([
            'table_id' => 'required',
            'product_id' => 'required',
            'action' => 'required|in:increment,decrement,delete',
        ]);

        return DB::transaction(function () use ($request) {
            $order = Order::where('table_id', $request->table_id)
                ->where('status', 'pending')
                ->first();

            if (!$order) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay don'], 404);
            }

            $detail = OrderDetail::where('order_id', $order->id)
                ->where('product_id', $request->product_id)
                ->first();

            if ($detail) {
                if ($request->action === 'increment') {
                    $detail->increment('quantity');
                } elseif ($request->action === 'decrement') {
                    $detail->quantity > 1 ? $detail->decrement('quantity') : $detail->delete();
                } elseif ($request->action === 'delete') {
                    $detail->delete();
                }

                if ($order->orderDetails()->count() === 0) {
                    $order->delete();
                    Table::where('id', $request->table_id)->update(['status' => 0]);

                    return response()->json(['success' => true, 'message' => 'Ban trong', 'data' => null]);
                }

                $this->updateTotalAmount($order);
            }

            return response()->json(['success' => true, 'message' => 'Cap nhat thanh cong']);
        });
    }

    public function checkout(Request $request)
    {
        $request->validate([
            'table_id' => 'required|exists:tables,id',
            'payment_method' => 'nullable|string',
        ]);

        return DB::transaction(function () use ($request) {
            $order = Order::where('table_id', $request->table_id)
                ->where('status', 'pending')
                ->first();

            if (!$order) {
                return response()->json(['success' => false, 'message' => 'Khong tim thay don'], 404);
            }

            $this->completeOrder($order, $request->input('payment_method', 'Tiền mặt'));

            return response()->json(['success' => true, 'message' => 'Thanh toan hoan tat']);
        });
    }

    public function paymentStatus($orderId)
    {
        $order = Order::find($orderId);

        if (!$order) {
            return response()->json(['success' => false, 'status' => 'not_found'], 404);
        }

        $paymentCode = $this->prepareOrderForSepay($order);

        return response()->json([
            'success' => true,
            'status' => $order->status,
            'payment_method' => $order->payment_method,
            'sepay_code' => $paymentCode,
            'paid_at' => $order->paid_at,
        ]);
    }

    public function prepareSepayPayment(Request $request, $orderId)
    {
        $order = Order::find($orderId);

        if (!$order) {
            return response()->json(['success' => false, 'message' => 'Khong tim thay don'], 404);
        }

        if ($order->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Don nay da thanh toan hoac khong con cho xu ly',
            ], 409);
        }

        $paymentCode = $this->prepareOrderForSepay($order);

        return response()->json([
            'success' => true,
            'sepay_code' => $paymentCode,
            'amount' => (float) $order->total_amount,
            'payment_method' => $order->payment_method,
        ]);
    }

    public function sepayWebhook(Request $request)
    {
        $apiKey = config('services.sepay.api_key');

        if (!empty($apiKey)) {
            $expectedAuth = 'Apikey ' . $apiKey;
            $actualAuth = $request->header('Authorization', '');

            if (!hash_equals($expectedAuth, $actualAuth)) {
                return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
            }
        }

        $data = $request->all();
        $transactionId = isset($data['id']) ? (string) $data['id'] : null;

        if (empty($transactionId)) {
            return response()->json(['success' => false, 'message' => 'Missing transaction id'], 422);
        }

        $inserted = DB::table('sepay_webhook_logs')->insertOrIgnore([
            'transaction_id' => $transactionId,
            'payload' => json_encode($data, JSON_UNESCAPED_UNICODE),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        if ($inserted === 0) {
            return response()->json(['success' => true, 'message' => 'Already processed']);
        }

        if (($data['transferType'] ?? '') !== 'in') {
            return response()->json(['success' => true, 'message' => 'Ignored non-incoming transfer']);
        }

        $paymentCode = $this->extractSepayCode($data);
        $transferAmount = (float) ($data['transferAmount'] ?? 0);

        if (!$paymentCode || $transferAmount <= 0) {
            return response()->json(['success' => true, 'message' => 'No matched payment code']);
        }

        $order = Order::where('sepay_code', $paymentCode)->first();

        if (!$order && preg_match('/^CAFE(\d+)$/', $paymentCode, $matches)) {
            $order = Order::find((int) $matches[1]);
        }

        if (!$order) {
            Log::warning('SePay webhook did not match any order', [
                'transaction_id' => $transactionId,
                'payment_code' => $paymentCode,
            ]);

            return response()->json(['success' => true, 'message' => 'Order not found']);
        }

        if ($order->status === 'pending' && (float) $order->total_amount <= $transferAmount) {
            DB::transaction(function () use ($order, $paymentCode, $transactionId) {
                $order->refresh();

                if ($order->status !== 'pending') {
                    return;
                }

                $order->update([
                    'status' => 'completed',
                    'payment_method' => 'Chuyển khoản',
                    'sepay_code' => $paymentCode,
                    'sepay_transaction_id' => $transactionId,
                    'paid_at' => now(),
                    'updated_at' => now(),
                ]);

                Table::where('id', $order->table_id)->update(['status' => 0]);
            });
        }

        return response()->json(['success' => true]);
    }

    public function listOrders(Request $request)
    {
        $status = $request->input('status');
        $filter = $request->input('filter');

        $query = Order::with(['table', 'orderDetails.product']);

        if ($request->filled('status') && $status !== 'all') {
            $query->where('status', $status);
        }

        if ($request->filled('filter')) {
            if ($filter === 'today') {
                $query->whereDate('updated_at', date('Y-m-d'));
            } elseif ($filter === 'week') {
                $query->whereBetween('updated_at', [
                    now()->startOfWeek(),
                    now()->endOfWeek(),
                ]);
            }
        }

        $orders = $query->orderBy('updated_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $orders,
        ]);
    }

    private function updateTotalAmount(Order $order): void
    {
        $total = $order->orderDetails()->sum(DB::raw('quantity * price'));
        $order->update(['total_amount' => $total]);
    }

    private function completeOrder(Order $order, string $paymentMethod): void
    {
        $order->update([
            'status' => 'completed',
            'updated_at' => now(),
            'payment_method' => $paymentMethod,
            'paid_at' => now(),
        ]);

        Table::where('id', $order->table_id)->update(['status' => 0]);
    }

    private function paymentCodeForOrder(Order $order): string
    {
        return $order->sepay_code ?: 'CAFE' . $order->id;
    }

    private function prepareOrderForSepay(Order $order): string
    {
        $paymentCode = $this->paymentCodeForOrder($order);

        if ($order->sepay_code !== $paymentCode || $order->payment_method !== 'Chuyển khoản') {
            $order->update([
                'payment_method' => 'Chuyển khoản',
                'sepay_code' => $paymentCode,
            ]);
        }

        return $paymentCode;
    }

    private function extractSepayCode(array $data): ?string
    {
        foreach (['code', 'content', 'description'] as $field) {
            $value = (string) ($data[$field] ?? '');

            if (preg_match('/CAFE\d+/i', $value, $matches)) {
                return strtoupper($matches[0]);
            }
        }

        return null;
    }
}
