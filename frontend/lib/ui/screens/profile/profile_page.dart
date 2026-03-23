import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/di_config.dart';
import '../../router/app_router.gr.dart';
import '../../../data/constant/enums.dart';
import 'cubit/profile_cubit.dart';
import 'cubit/profile_state.dart';
import '../../../data/api/api_client.dart';
import '../../../resource/app_strings.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == BaseStatus.success) {
            if (state.user == null) {
              // Show dialog for password/name change success which requires relogin
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Thành công'),
                  content: const Text(
                    'Thông tin đã được cập nhật. Vui lòng đăng nhập lại để áp dụng thay đổi.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.router.replaceAll([const LoginRoute()]);
                      },
                      child: const Text('Đăng nhập'),
                    ),
                  ],
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.actionSuccessful),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else if (state.status == BaseStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? AppStrings.anErrorOccurred),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final user = state.user;
          final avatarUrl = user?.avatarUrl;
          final fullAvatarUrl = avatarUrl != null
              ? '${ApiClient.baseUrl}$avatarUrl'
              : null;

          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.myProfile)),
            body: state.status == BaseStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          children: [
                            _buildAvatarSection(context, fullAvatarUrl, user),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user?.name ?? 'User Name',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: const Color(0xFF8B5CF6),
                                  ),
                                  onPressed: () => _showEditNameDialog(
                                    context,
                                    user?.name ?? '',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'email@example.com',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user?.role.displayName ?? 'Role',
                                style: const TextStyle(
                                  color: const Color(0xFF8B5CF6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                            _buildOptionTile(
                              context,
                              icon: Icons.lock_outline,
                              title: AppStrings.changePassword,
                              onTap: () => _showChangePasswordDialog(context),
                            ),
                            const Divider(),
                            _buildOptionTile(
                              context,
                              icon: Icons.logout,
                              title: AppStrings.logout,
                              isDestructive: true,
                              onTap: () => _showLogoutConfirmation(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, String? avatarUrl, user) {
    final initial = (user?.name ?? 'U').isNotEmpty
        ? (user?.name ?? 'U').trim()[0].toUpperCase()
        : 'U';
    
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: const Color(0xFF8B5CF6),
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final nameController = TextEditingController(text: currentName);
    final cubit = context.read<ProfileCubit>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi tên hiển thị'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Họ và tên'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(context);
              cubit.updateProfile(name: nameController.text.trim());
            },
            child: const Text(AppStrings.update),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final oldPasswordController = TextEditingController();
    final confirmController = TextEditingController();
    final cubit = context.read<ProfileCubit>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: AppStrings.currentPassword,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: AppStrings.newPassword,
                hintText: 'Tối thiểu 6 ký tự',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: AppStrings.confirmPassword,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (oldPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập mật khẩu hiện tại'),
                  ),
                );
                return;
              }
              if (passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.passwordTooShort)),
                );
                return;
              }
              if (passwordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.passwordsDoNotMatch)),
                );
                return;
              }
              Navigator.pop(context);
              cubit.changePassword(
                oldPassword: oldPasswordController.text,
                newPassword: passwordController.text,
              );
            },
            child: const Text(AppStrings.update),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF8B5CF6),
        size: 30,
      ), // Increased
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18, // Increased
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 24), // Increased
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8,
      ), // Increased spacing
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileCubit>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              AppStrings.logout,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
