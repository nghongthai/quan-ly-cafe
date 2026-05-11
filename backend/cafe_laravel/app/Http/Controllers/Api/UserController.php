<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

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
    public function store(Request $request)
{
    $request->validate([
        'name' => 'required|string|max:255',
        'username' => 'required|string|unique:users,username',
        'password' => 'required|string|min:6',
        'role' => 'required|string'
    ]);

    $user = User::create([
        'name' => $request->name,
        'username' => $request->username,
        'password' => bcrypt($request->password),
        'role' => $request->role,
    ]);
    

    return response()->json(['success' => true, 'data' => $user], 201);
}
public function show($id)
{
    $user = User::find($id);
    if ($user) {
        return response()->json($user);
    }
    return response()->json(['message' => 'Không tìm thấy'], 404);
}
}