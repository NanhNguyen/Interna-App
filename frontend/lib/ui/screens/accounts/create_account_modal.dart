import 'package:flutter/material.dart';
import '../../di/di_config.dart';
import '../../../data/service/user_service.dart';

/// Shows the account creation form as a modal dialog.
Future<void> showCreateAccountModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => const CreateAccountModal(),
  );
}

class CreateAccountModal extends StatefulWidget {
  const CreateAccountModal({super.key});

  @override
  State<CreateAccountModal> createState() => _CreateAccountModalState();
}

class _CreateAccountModalState extends State<CreateAccountModal> {
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchManagers() async {
    try {
      final managers = await getIt<UserService>().getManagers();
      if (mounted) {
        setState(() {
          _managers = managers;
        });
      }
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
        Navigator.of(context).pop(); // Close modal
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
    final color = const Color(0xFF8B5CF6);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF0EA5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Cấp tài khoản mới',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Họ và tên',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? 'Vui lòng nhập Email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) =>
                            value!.length < 6 ? 'Mật khẩu phải từ 6 ký tự' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Vai trò (Role)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.badge),
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
                          decoration: InputDecoration(
                            labelText: 'Quản lý trực tiếp',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.supervisor_account),
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // ── Footer ──
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: color.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
