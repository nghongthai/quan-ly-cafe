<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Shift extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'start_time',
        'end_time',
        'opening_cash',
        'cash_revenue',
        'bank_revenue',
        'closing_cash',
        'total_revenue',
        'total_orders',
        'total_products',
        'status',
        'note',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
