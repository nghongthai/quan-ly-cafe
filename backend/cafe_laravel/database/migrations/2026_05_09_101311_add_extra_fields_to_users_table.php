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
            // Thêm các trường mới theo giao diện bạn gửi
            $table->string('phone')->nullable()->after('username'); // Số điện thoại
            $table->string('email')->nullable()->after('phone');    // Gmail
            $table->string('shift')->nullable()->after('role');     // Ca làm (VD: 08:00 - 17:00)
        });
    }

    /**
     * Hoàn tác migration (Xóa cột).
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['phone', 'email', 'shift']);
        });
    }
};