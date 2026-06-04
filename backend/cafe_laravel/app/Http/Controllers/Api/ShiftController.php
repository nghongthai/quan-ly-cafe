<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderDetail;
use App\Models\Shift;
use Carbon\Carbon;
use Illuminate\Http\Request;

class ShiftController extends Controller
{
    private const OPENING_CASH = 1000000;

    public function current(Request $request)
    {
        $shift = $this->openShiftQuery($request->query('user_id'))->first();

        return response()->json([
            'status' => 'success',
            'has_open_shift' => $shift !== null,
            'data' => $shift ? $shift->load('user') : null,
        ]);
    }

    public function open(Request $request)
    {
        $request->validate([
            'user_id' => 'nullable|exists:users,id',
            'opening_cash' => 'nullable|numeric|min:0',
            'note' => 'nullable|string',
        ]);

        $existing = $this->openShiftQuery($request->input('user_id'))->first();
        if ($existing) {
            return response()->json([
                'status' => 'success',
                'message' => 'Ca dang mo',
                'data' => $existing->load('user'),
            ]);
        }

        $shift = Shift::create([
            'user_id' => $request->input('user_id'),
            'start_time' => now(),
            'opening_cash' => $request->input('opening_cash', self::OPENING_CASH),
            'cash_revenue' => 0,
            'bank_revenue' => 0,
            'total_revenue' => 0,
            'closing_cash' => 0,
            'total_orders' => 0,
            'total_products' => 0,
            'status' => 'open',
            'note' => $request->input('note'),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Mo ca thanh cong',
            'data' => $shift->load('user'),
        ], 201);
    }

    public function dailyReport(Request $request)
    {
        $shift = $this->openShiftQuery($request->query('user_id'))->first();

        if (!$shift) {
            return response()->json([
                'status' => 'success',
                'has_open_shift' => false,
                'data' => $this->emptyReport(),
            ]);
        }

        return response()->json([
            'status' => 'success',
            'has_open_shift' => true,
            'data' => $this->buildReportForShift($shift, now()),
        ]);
    }

    public function close(Request $request)
    {
        $request->validate([
            'user_id' => 'nullable|exists:users,id',
            'note' => 'nullable|string',
        ]);

        $shift = $this->openShiftQuery($request->input('user_id'))->first();

        if (!$shift) {
            return response()->json([
                'status' => 'error',
                'message' => 'Chua co ca dang mo',
            ], 404);
        }

        $endTime = now();
        $report = $this->buildReportForShift($shift, $endTime);

        $shift->update([
            'end_time' => $endTime,
            'cash_revenue' => $report['cash_revenue'],
            'bank_revenue' => $report['bank_revenue'],
            'total_revenue' => $report['total_revenue'],
            'closing_cash' => $report['closing_cash'],
            'total_orders' => $report['total_orders'],
            'total_products' => $report['total_products'],
            'status' => 'closed',
            'note' => $request->input('note', $shift->note),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Dong ca thanh cong',
            'data' => $shift->fresh('user'),
        ]);
    }

    public function history()
    {
        return response()->json([
            'status' => 'success',
            'data' => Shift::with('user')
                ->where('status', 'closed')
                ->orderByDesc('end_time')
                ->orderByDesc('id')
                ->get(),
        ]);
    }

    public function show($id)
    {
        $shift = Shift::with('user')->find($id);

        if (!$shift) {
            return response()->json([
                'status' => 'error',
                'message' => 'Khong tim thay ca',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $shift,
        ]);
    }

    private function openShiftQuery($userId)
    {
        return Shift::with('user')
            ->where('status', 'open')
            ->whereDate('start_time', Carbon::now('Asia/Ho_Chi_Minh')->toDateString())
            ->when($userId, fn ($query) => $query->where('user_id', $userId))
            ->latest('start_time');
    }

    private function buildReportForShift(Shift $shift, Carbon $endTime): array
    {
        $orders = Order::where('status', 'completed')
            ->whereBetween('created_at', [$shift->start_time, $endTime])
            ->get();

        $cashMethods = ['Tiền mặt', 'Tiá»n máº·t', 'cash'];
        $bankMethods = ['Chuyển khoản', 'Chuyá»ƒn khoáº£n', 'bank_transfer'];
        $cashRevenue = (double) $orders->whereIn('payment_method', $cashMethods)->sum('total_amount');
        $bankRevenue = (double) $orders->whereIn('payment_method', $bankMethods)->sum('total_amount');
        $totalRevenue = $cashRevenue + $bankRevenue;
        $orderIds = $orders->pluck('id');

        return [
            'id' => $shift->id,
            'user_id' => $shift->user_id,
            'user' => $shift->user,
            'start_time' => $shift->start_time,
            'end_time' => $endTime,
            'opening_cash' => (double) $shift->opening_cash,
            'cash_revenue' => $cashRevenue,
            'bank_revenue' => $bankRevenue,
            'total_revenue' => $totalRevenue,
            'closing_cash' => (double) $shift->opening_cash + $cashRevenue,
            'total_orders' => $orders->count(),
            'total_products' => (int) OrderDetail::whereIn('order_id', $orderIds)->sum('quantity'),
            'status' => $shift->status,
            'note' => $shift->note,
        ];
    }

    private function emptyReport(): array
    {
        return [
            'opening_cash' => self::OPENING_CASH,
            'cash_revenue' => 0,
            'bank_revenue' => 0,
            'total_revenue' => 0,
            'closing_cash' => self::OPENING_CASH,
            'total_orders' => 0,
            'total_products' => 0,
        ];
    }
}
