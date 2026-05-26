<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens; // Thêm nếu bạn dùng Sanctum cho API

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',    // Sắp xếp lại và giữ 'email' làm trường chính
        'password',
        'role',
        'phone',    // Mới thêm
        'shift',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    // Thay vì dùng function casts(), hãy dùng thuộc tính này cho ổn định
    protected $casts = [
        'password' => 'hashed',
    ];
}