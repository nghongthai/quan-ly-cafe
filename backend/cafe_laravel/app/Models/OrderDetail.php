<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderDetail extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'product_id',
        'quantity',
        'price',
    ];

    /**
     * Liên kết: Một dòng chi tiết thuộc về một sản phẩm
     */
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}