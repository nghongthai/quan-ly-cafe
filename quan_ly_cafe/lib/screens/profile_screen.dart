import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quan_ly_cafe/screens/api_constants.dart';
import 'package:quan_ly_cafe/screens/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String userRole = 'Nh\u00e2n vi\u00ean';
  bool isEditing = false;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/me/${widget.userId}"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          nameController.text = data['name'] ?? '';
          userRole = data['role'] ?? 'Nh\u00e2n vi\u00ean';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Loi tai thong tin ca nhan: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> updateUserProfile() async {
    if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
      _showSnackBar('Vui l\u00f2ng nh\u1eadp h\u1ecd t\u00ean v\u00e0 email');
      return;
    }

    if (!emailController.text.trim().contains('@')) {
      _showSnackBar('Email kh\u00f4ng h\u1ee3p l\u1ec7');
      return;
    }

    setState(() => isSaving = true);

    try {
      final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/profile/${widget.userId}"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        final user = data['data'] ?? {};
        if (!mounted) return;
        setState(() {
          nameController.text = user['name'] ?? nameController.text;
          emailController.text = user['email'] ?? emailController.text;
          phoneController.text = user['phone'] ?? phoneController.text;
          isEditing = false;
        });
        _showSnackBar('C\u1eadp nh\u1eadt th\u00f4ng tin th\u00e0nh c\u00f4ng');
      } else {
        _showSnackBar(data['message'] ?? 'Kh\u00f4ng th\u1ec3 c\u1eadp nh\u1eadt th\u00f4ng tin');
      }
    } catch (e) {
      _showSnackBar('Kh\u00f4ng th\u1ec3 k\u1ebft n\u1ed1i \u0111\u1ebfn m\u00e1y ch\u1ee7');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Th\u00f4ng tin c\u00e1 nh\u00e2n',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFE8EAF6),
                      child: Icon(Icons.person, size: 45, color: Color(0xFF1A237E)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      nameController.text.isEmpty ? 'Ng\u01b0\u1eddi d\u00f9ng' : nameController.text,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userRole,
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () => setState(() => isEditing = !isEditing),
                          icon: Icon(isEditing ? Icons.close : Icons.edit, size: 16),
                          label: Text(isEditing ? 'H\u1ee7y s\u1eeda' : 'Ch\u1ec9nh s\u1eeda'),
                          style: TextButton.styleFrom(foregroundColor: Colors.orange),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChangePasswordScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.lock_reset, size: 16),
                          label: const Text('\u0110\u1ed5i m\u1eadt kh\u1ea9u'),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF1A237E)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildInfoField('H\u1ecd t\u00ean', nameController),
                    _buildInfoField('S\u0110T', phoneController, keyboardType: TextInputType.phone),
                    _buildInfoField('Email', emailController, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    if (isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: isSaving ? null : updateUserProfile,
                          child: isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'L\u01b0u thay \u0111\u1ed5i',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: isEditing,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: isEditing ? Colors.white : Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
