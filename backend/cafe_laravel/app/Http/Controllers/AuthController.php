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
     * Xử lý Đăng nhập (Đã sửa từ username thành email để hết lỗi SQL)
     */
    public function login(Request $request)
    {
        // 1. Kiểm tra dữ liệu đầu vào (Sửa thành email)
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $credentials = $request->only('email', 'password');

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
                    'email' => $user->email, // Trả về email thay vì username
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

    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Du lieu khong hop le',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'Email khong ton tai trong he thong'
            ], 404);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Cap nhat mat khau thanh cong'
        ], 200);
    }

    public function changePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'current_password' => 'required|string',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Du lieu khong hop le',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Email hoac mat khau hien tai khong dung'
            ], 401);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Doi mat khau thanh cong'
        ], 200);
    }

    /**
     * Xử lý Đăng ký (Đã sửa từ username thành email)
     */
    public function register(Request $request)
    {
        // Kiểm tra dữ liệu đăng ký
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users', // Sửa ở đây
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Dữ liệu không hợp lệ hoặc email đã tồn tại',
                'errors' => $validator->errors()
            ], 422);
        }

        // Tạo User mới
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email, // Lưu vào cột email
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
