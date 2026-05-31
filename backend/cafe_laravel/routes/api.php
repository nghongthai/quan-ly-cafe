<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\DashboardController;
use App\Models\Table;

// --- 1. AUTHENTICATION ---
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/logout', [AuthController::class, 'logout']);

// --- 2. QUẢN LÝ NHÂN VIÊN ---
Route::get('/users', [UserController::class, 'index']);
Route::post('/users', [UserController::class, 'store']);
Route::delete('/users/{id}', [UserController::class, 'destroy']);
Route::post('/users/{id}', [UserController::class, 'update']);

// --- 3. TABLES (Quản lý bàn) ---
Route::get('/tables', function() { 
    // SỬA TẠI ĐÂY: Sử dụng 'pending' thay vì 'Chờ xử lý' để khớp với Controller.
    // Nạp thêm orderDetails và product để Flutter có danh sách món hiển thị.
    $tables = Table::with(['orders' => function($query) {
        $query->where('status', 'pending')->with('orderDetails.product');
    }])->get();

    return $tables->map(function($table) {
        $activeOrder = $table->orders->first();
        return [
            'id' => $table->id,
            'name' => $table->name,
            'status' => $table->status, 
            'total_amount' => $activeOrder ? (float)$activeOrder->total_amount : 0,
            // QUAN TRỌNG: Gửi kèm object đơn hàng đầy đủ để màn hình chi tiết hiển thị được món
            'active_order' => $activeOrder, 
        ];
    });
});

// --- 4. PRODUCTS ---
Route::get('/products', [OrderController::class, 'getProducts']); 

// --- 5. ORDERS ---
Route::get('/list-orders', [OrderController::class, 'listOrders']); 
Route::get('/order/table/{tableId}', [OrderController::class, 'getOrderByTable']); 
Route::post('/order/add-product', [OrderController::class, 'addProduct']);
Route::post('/order/checkout', [OrderController::class, 'checkout']); 
Route::post('/order/update-item', [OrderController::class, 'updateOrderDetail']);
Route::get('/me/{id}', [UserController::class, 'show']);
Route::get('/dashboard/stats', [DashboardController::class, 'getStats']);
Route::get('/dashboard/revenue-report', [DashboardController::class, 'getRevenueReport']);