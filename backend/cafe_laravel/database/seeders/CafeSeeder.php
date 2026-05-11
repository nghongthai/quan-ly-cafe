<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Area;
use App\Models\Table;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB; // Thêm DB để xóa dữ liệu

class CafeSeeder extends Seeder
{
    public function run(): void
    {
        // --- 0. Dọn dẹp dữ liệu cũ (Tùy chọn nhưng nên làm) ---
        // Tắt kiểm tra khóa ngoại để xóa sạch bảng mà không bị lỗi ràng buộc
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        User::truncate();
        Product::truncate();
        Table::truncate();
        Area::truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // --- 1. Tạo các khu vực ---
        $trongNha = Area::create(['name' => 'Cafe Trong Nhà']);
        $ngoaiTroi = Area::create(['name' => 'Cafe Ngoài Trời']);

        // --- 2. Tạo bàn cho khu vực Trong nhà ---
        for ($i = 1; $i <= 5; $i++) {
            Table::create([
                'area_id' => $trongNha->id,
                'name' => "Bàn $i",
                'status' => false
            ]);
        }

        // --- 3. Tạo bàn cho khu vực Ngoài trời ---
        for ($i = 6; $i <= 10; $i++) {
            Table::create([
                'area_id' => $ngoaiTroi->id,
                'name' => "Bàn $i",
                'status' => false
            ]);
        }

        // --- 4. Tạo 20 sản phẩm mẫu ---
        $products = [
            ['name' => 'Cafe Đen', 'price' => 20000],
            ['name' => 'Cafe Sữa', 'price' => 25000],
            ['name' => 'Bạc Xỉu', 'price' => 30000],
            ['name' => 'Cafe Muối', 'price' => 35000],
            ['name' => 'Trà Đào Cam Sả', 'price' => 45000],
            ['name' => 'Trà Vải', 'price' => 40000],
            ['name' => 'Trà Dâu', 'price' => 38000],
            ['name' => 'Nước Cam', 'price' => 40000],
            ['name' => 'Nước Ép Dưa Hấu', 'price' => 35000],
            ['name' => 'Sinh Tố Bơ', 'price' => 50000],
            ['name' => 'Sinh Tố Xoài', 'price' => 45000],
            ['name' => 'Sữa Chua Trân Châu', 'price' => 35000],
            ['name' => 'Matcha Latte', 'price' => 45000],
            ['name' => 'Chocolate Đá Xay', 'price' => 55000],
            ['name' => 'Soda Chanh', 'price' => 30000],
            ['name' => 'Soda Việt Quất', 'price' => 35000],
            ['name' => 'Trà Sữa Truyền Thống', 'price' => 30000],
            ['name' => 'Trà Sữa Thái Xanh', 'price' => 30000],
            ['name' => 'Hồng Trà Sữa', 'price' => 35000],
            ['name' => 'Trà Oolong Kem Phô Mai', 'price' => 50000],
        ];

        foreach ($products as $product) {
            Product::create($product);
        }

        // --- 5. Thêm tài khoản Admin mẫu ---
        User::create([
            'name' => 'Quản trị viên',
            'username' => 'admin',
            'password' => Hash::make('123456'),
            'role' => 'admin',
        ]);

        // --- 6. Thêm tài khoản Nhân viên mẫu ---
        User::create([
            'name' => 'Nhân viên A',
            'username' => 'staff1',
            'password' => Hash::make('123456'),
            'role' => 'staff',
        ]);
        User::create([
        'name' => 'Nguyễn Văn Anh',
        'username' => 'anhnv',
        'password' => Hash::make('123456'),
        'role' => 'Thu ngân',
    ]);

    User::create([
        'name' => 'Lê Thị Bình',
        'username' => 'binhlt',
        'password' => Hash::make('123456'),
        'role' => 'Phục vụ',
    ]);

    User::create([
        'name' => 'Trần Văn Cường',
        'username' => 'cuongtv',
        'password' => Hash::make('123456'),
        'role' => 'Pha chế',
    ]);

    User::create([
        'name' => 'Phạm Minh Đức',
        'username' => 'ducpm',
        'password' => Hash::make('123456'),
        'role' => 'Phục vụ',
    ]);

    }
}