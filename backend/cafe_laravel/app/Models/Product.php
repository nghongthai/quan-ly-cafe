<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    // Cho phép lưu các trường này vào DB
    protected $fillable = ['name', 'price'];

    // Thiết lập quan hệ: Một sản phẩm có thể xuất hiện trong nhiều chi tiết đơn hàng
    public function orderDetails()
    {
        return $this->hasMany(OrderDetail::class);
    }
}