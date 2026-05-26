<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Chạy migration để thêm cột.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Sửa 'after('username')' thành 'after('name')' (hoặc after('id') nếu không chắc chắn)
            $table->string('phone')->nullable()->after('name'); // Số điện thoại
            
            // ĐÃ XÓA dòng thêm cột 'email' vì bảng users mặc định luôn có sẵn cột này rồi!
            
            // Sửa vị trí 'after('role')' thành 'after('password')' (vì bảng users gốc mặc định không có cột role)
            $table->string('shift')->nullable()->after('password'); // Ca làm (VD: 08:00 - 17:00)
        });
    }

    /**
     * Hoàn tác migration (Xóa cột).
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Chỉ xóa 2 cột thực sự được thêm mới vào
            $table->dropColumn(['phone', 'shift']);
        });
    }
};