<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    /**
     * Xử lý Đăng nhập (Khớp với màn hình 2 trong image_7578f7.png)
     */
    public function login(Request $request)
    {
        // 1. Kiểm tra dữ liệu đầu vào
        $request->validate([
            'username' => 'required',
            'password' => 'required',
        ]);

        $credentials = $request->only('username', 'password');

        // 2. Thực hiện đăng nhập
        if (Auth::attempt($credentials)) {
            $user = Auth::user();
            
            // 3. Trả về thông tin kèm theo Role
            return response()->json([
                'status' => 'success',
                'message' => 'Đăng nhập thành công',
                'data' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'username' => $user->username,
                    'role' => $user->role, 
                ]
            ], 200);
        }

        // 4. Thất bại
        return response()->json([
            'status' => 'error',
            'message' => 'Tài khoản hoặc mật khẩu không chính xác'
        ], 401);
    }

    /**
     * Xử lý Đăng ký (Khớp với màn hình 1 trong image_7578f7.png)
     */
    public function register(Request $request)
    {
        // Kiểm tra dữ liệu đăng ký
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Dữ liệu không hợp lệ hoặc username đã tồn tại',
                'errors' => $validator->errors()
            ], 422);
        }

        // Tạo User mới
        $user = User::create([
            'name' => $request->name,
            'username' => $request->username,
            'password' => Hash::make($request->password),
            'role' => 'staff', // Mặc định đăng ký mới là nhân viên
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Tạo tài khoản thành công',
            'data' => $user
        ], 201);
    }

    /**
     * Đăng xuất
     */
    public function logout()
    {
        Auth::logout();
        return response()->json([
            'status' => 'success',
            'message' => 'Đã đăng xuất'
        ]);
    }
}