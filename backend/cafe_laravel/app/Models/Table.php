<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Table extends Model
{
    use HasFactory;

    protected $fillable = ['area_id', 'name', 'status'];

    // Thiết lập quan hệ: Một bàn thuộc về một khu vực
    public function area()
    {
        return $this->belongsTo(Area::class);
    }

    // Thiết lập quan hệ: Một bàn có thể có nhiều đơn hàng (theo thời gian)
    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    // Hàm hỗ trợ lấy đơn hàng đang hoạt động (chưa thanh toán) của bàn
    public function activeOrder()
    {
        return $this->hasOne(Order::class)->where('status', 'pending');
    }
}