import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/di_config.dart';
import '../../../data/service/user_service.dart';
import '../main/cubit/main_cubit.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'INTERN';
  String? _selectedManagerId;
  List<Map<String, dynamic>> _managers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchManagers();
  }

  Future<void> _fetchManagers() async {
    try {
      final managers = await getIt<UserService>().getManagers();
      setState(() {
        _managers = managers;
      });
    } catch (e) {
      debugPrint('Error fetching managers: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Require manager selection if role is INTERN
    if (_selectedRole == 'INTERN' && _selectedManagerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn Quản lý trực tiếp cho Thực tập sinh'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await getIt<UserService>().createAccount(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        managerId: _selectedRole == 'INTERN' ? _selectedManagerId : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo tài khoản thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          _selectedRole = 'INTERN';
          _selectedManagerId = null;
        });

        // Chuyển về màn hình chính sau khi tạo xong
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            getIt<MainCubit>().setIndex(0);
          }
        });
      }
    } catch (e) {
      String errorMsg = 'Có lỗi xảy ra';
      if (e is dynamic && e.toString().contains('409')) {
        errorMsg = 'Email đã tồn tại trên hệ thống.';
      } else if (e is dynamic && e.toString().contains('401')) {
        errorMsg = 'Bạn không có quyền thực hiện thao tác này.';
      } else if (e is dynamic && e.toString().contains('400')) {
        errorMsg = 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
      } else {
        errorMsg = e.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cấp tài khoản mới'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<MainCubit>().setIndex(0),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập Email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? 'Mật khẩu phải từ 6 ký tự' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò (Role)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'INTERN',
                    child: Text('Thực tập sinh (Intern)'),
                  ),
                  DropdownMenuItem(
                    value: 'MANAGER',
                    child: Text('Quản lý (Manager)'),
                  ),
                  DropdownMenuItem(value: 'HR', child: Text('Nhân sự (HR)')),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedRole = val!;
                    if (val != 'INTERN') _selectedManagerId = null;
                  });
                },
              ),
              if (_selectedRole == 'INTERN') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedManagerId,
                  decoration: const InputDecoration(
                    labelText: 'Quản lý trực tiếp',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.supervisor_account),
                  ),
                  hint: const Text('Chọn Quản lý'),
                  items: _managers.map((m) {
                    return DropdownMenuItem<String>(
                      value: m['_id'],
                      child: Text(m['name'] ?? 'Không tên'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedManagerId = val;
                    });
                  },
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF7678ED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'TẠO TÀI KHOẢN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
