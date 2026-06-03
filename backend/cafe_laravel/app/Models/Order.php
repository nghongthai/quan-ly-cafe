<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'table_id',
        'total_amount',
        'status',
        'payment_method', // 'cash', 'card', 'online'
        'sepay_code',
        'sepay_transaction_id',
        'paid_at',
    ];

    /**
     * Liên kết: Một đơn hàng thuộc về một bàn
     */
    public function table()
    {
        return $this->belongsTo(Table::class);
    }

    /**
     * Liên kết: Một đơn hàng có nhiều chi tiết hóa đơn (món ăn)
     */
    public function orderDetails()
    {
        return $this->hasMany(OrderDetail::class);
    }
}
