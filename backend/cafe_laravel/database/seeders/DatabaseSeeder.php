<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Gọi CafeSeeder để chạy các lệnh tạo Bàn, Món ăn và Admin mà bạn đã viết
        $this->call([
            CafeSeeder::class,
        ]);
    }
}