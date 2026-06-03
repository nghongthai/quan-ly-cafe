<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Table;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class SePayWebhookController extends Controller
{
    public function handle(Request $request)
    {
        Log::info('SEPAY WEBHOOK', $request->all());

        $apiKey = config('services.sepay.api_key');
        if (!empty($apiKey)) {
            $expectedAuth = 'Apikey ' . $apiKey;
            $actualAuth = $request->header('Authorization', '');

            if (!hash_equals($expectedAuth, $actualAuth)) {
                return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
            }
        }

        $data = $request->all();
        $transactionId = $this->transactionIdFromPayload($data);

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

        $paymentCode = $this->extractPaymentCode($data);
        $transferAmount = (float) ($data['transferAmount'] ?? $data['amount'] ?? 0);

        if (!$paymentCode || $transferAmount <= 0) {
            return response()->json(['success' => true, 'message' => 'No matched payment code']);
        }

        $order = $this->findOrderByPaymentCode($paymentCode);
        if (!$order) {
            Log::warning('SEPAY WEBHOOK ORDER NOT FOUND', [
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
                    'payment_method' => "Chuy\u{1EC3}n kho\u{1EA3}n",
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

    private function findOrderByPaymentCode(string $paymentCode): ?Order
    {
        $order = Order::where('sepay_code', $paymentCode)->first();

        if (!$order && preg_match('/^CAFE(?:_ORDER_)?(\d+)$/', $paymentCode, $matches)) {
            return Order::find((int) $matches[1]);
        }

        return $order;
    }

    private function extractPaymentCode(array $data): ?string
    {
        foreach (['code', 'content', 'description', 'transferContent'] as $field) {
            $value = (string) ($data[$field] ?? '');

            if (preg_match('/CAFE(?:_ORDER_)?\d+/i', $value, $matches)) {
                return strtoupper($matches[0]);
            }
        }

        return null;
    }

    private function transactionIdFromPayload(array $data): string
    {
        foreach (['id', 'referenceCode', 'gatewayTransactionId', 'transactionId'] as $field) {
            if (!empty($data[$field])) {
                return (string) $data[$field];
            }
        }

        return 'test_' . md5(json_encode($data, JSON_UNESCAPED_UNICODE));
    }
}
