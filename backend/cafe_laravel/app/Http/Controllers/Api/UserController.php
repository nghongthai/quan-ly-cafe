<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    // Lấy danh sách nhân viên để hiện lên App
    public function index()
    {
        $users = User::all();
        return response()->json($users);
    }

    // Xóa nhân viên theo ID
    public function destroy($id)
    {
        $user = User::find($id);
        if ($user) {
            $user->delete();
            return response()->json(['success' => true, 'message' => 'Đã xóa nhân viên']);
        }
        return response()->json(['success' => false, 'message' => 'Không tìm thấy'], 404);
    }

    // Thêm mới nhân viên / Quản trị viên
    public function store(Request $request)
    {
        // ✅ Đã sửa validate từ 'username' thành 'email' để khớp với DB
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|unique:users,email',
            'password' => 'required|string|min:6',
            'role' => 'required|string'
        ]);

        // ✅ Tạo user với trường 'email'
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password), // Dùng Hash::make đồng bộ với Seeder
            'role' => $request->role,
            'shift' => $request->shift ?? 'Chưa xếp ca', // Thêm trường ca làm việc dự phòng
        ]);

        return response()->json(['success' => true, 'data' => $user], 201);
    }
    public function update(Request $request, $id)
{
    // Tìm nhân viên theo ID
    $user = \App\Models\User::find($id); // Hoặc Model tương ứng của bạn (ví dụ: User)

    if (!$user) {
        return response()->json(['message' => 'Không tìm thấy nhân viên'], 404);
    }

    // Cập nhật vai trò mới từ Flutter gửi lên
    if ($request->has('role')) {
        $user->role = $request->input('role');
    }

    // Nếu Flutter có gửi thêm các thông tin khác muốn sửa thì bổ sung ở đây
    $user->save(); 

    return response()->json([
        'message' => 'Cập nhật vai trò thành công',
        'data' => $user
    ], 200);
}

    // Xem chi tiết 1 nhân viên
    public function show($id)
    {
        $user = User::find($id);
        if ($user) {
            return response()->json($user);
        }
        return response()->json(['message' => 'Không tìm thấy'], 404);
    }
}