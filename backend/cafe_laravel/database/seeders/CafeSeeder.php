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
            ['name' => 'Cafe Đen', 'price' => 20000, 'image' => 'cafe_den.png'],
            ['name' => 'Cafe Sữa', 'price' => 25000, 'image' => 'cafe_sữa.png'],
            ['name' => 'Bạc Xỉu', 'price' => 30000, 'image' => 'Bạc_xiu.png'],
            ['name' => 'Cafe Muối', 'price' => 35000, 'image' => 'cafe_muối.png'],
            ['name' => 'Trà Đào Cam Sả', 'price' => 45000, 'image' => 'Trà_dao_cam_sả.png'],
            ['name' => 'Trà Vải', 'price' => 40000, 'image' => 'Trà_vải.png'],
            ['name' => 'Trà Dâu', 'price' => 38000, 'image' => 'Trà_dau.png'],
            ['name' => 'Nước Cam', 'price' => 40000, 'image' => 'Nước_cam.png'],
            ['name' => 'Nước Ép Dưa Hấu', 'price' => 35000, 'image' => 'Ép_dưa_hấu.png'],
            ['name' => 'Sinh Tố Bơ', 'price' => 50000, 'image' => 'Sinh_tố_bơ.png'],
            ['name' => 'Sinh Tố Xoài', 'price' => 45000, 'image' => 'Sinh_tố_xoài.png'],
            ['name' => 'Sữa Chua Trân Châu', 'price' => 35000, 'image' => 'Sữachua_trân_châu.png'],
            ['name' => 'Matcha Latte', 'price' => 45000, 'image' => 'Matchalate.png'],
            ['name' => 'Chocolate Đá Xay', 'price' => 55000, 'image' => 'Chocolate_đá_xay.png'],
            ['name' => 'Soda Chanh', 'price' => 30000, 'image' => 'So_đa_chanh.png'],
            ['name' => 'Soda Việt Quất', 'price' => 35000, 'image' => 'Soda_việt_quất.png'],
            ['name' => 'Trà Sữa Truyền Thống', 'price' => 30000, 'image' => 'Trà sữa truyền thống.png'],
            ['name' => 'Trà Thái Xanh', 'price' => 30000, 'image' => 'Trà thái xanh.png'],
            ['name' => 'Hồng Trà Sữa', 'price' => 35000, 'image' => 'Hồng trà sữa.png'],
            ['name' => 'Trà Oolong Kem Phô Mai', 'price' => 50000, 'image' => 'Trà ôlong kem ô mai.png'],
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