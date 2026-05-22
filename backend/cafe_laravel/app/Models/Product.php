<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    // Cập nhật: Thêm 'image' vào đây để Laravel cho phép lưu tên file ảnh
    protected $fillable = ['name', 'price', 'image'];

    // Thiết lập quan hệ: Một sản phẩm có thể xuất hiện trong nhiều chi tiết đơn hàng
    public function orderDetails()
    {
        return $this->hasMany(OrderDetail::class);
    }
}