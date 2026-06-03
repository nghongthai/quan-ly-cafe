<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Shift;
use Carbon\Carbon;
use Illuminate\Http\Request;

class ShiftController extends Controller
{
    private const OPENING_CASH = 1000000;

    public function close(Request $request)
    {
        $request->validate([
            'user_id' => 'nullable|exists:users,id',
            'note' => 'nullable|string',
        ]);

        $today = Carbon::today();

        $ordersQuery = Order::where('status', 'completed')
            ->whereDate('updated_at', $today);

        $totalRevenue = (float) (clone $ordersQuery)->sum('total_amount');
        $totalOrders = (int) (clone $ordersQuery)->count();
        $openingCash = self::OPENING_CASH;
        $closingCash = $openingCash + $totalRevenue;

        $shift = Shift::create([
            'user_id' => $request->input('user_id'),
            'start_time' => $today->copy()->startOfDay(),
            'end_time' => now(),
            'opening_cash' => $openingCash,
            'closing_cash' => $closingCash,
            'total_revenue' => $totalRevenue,
            'total_orders' => $totalOrders,
            'note' => $request->input('note'),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Dong ca thanh cong',
            'data' => $shift->load('user'),
        ], 201);
    }
}
