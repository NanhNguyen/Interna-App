import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/di_config.dart';
import '../../router/app_router.gr.dart';
import '../../../data/constant/enums.dart';
import 'cubit/login_cubit.dart';
import 'cubit/login_state.dart';
import '../../../resource/app_strings.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: const LoginPageView(),
    );
  }
}

class LoginPageView extends StatefulWidget {
  const LoginPageView({super.key});

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status == BaseStatus.success) {
          FocusScope.of(context).unfocus();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              context.router.replace(const MainRoute());
            }
          });
        } else if (state.status == BaseStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? AppStrings.loginFailed),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blue.shade900,
        body: Stack(
          children: [
            // Static Background with RepaintBoundary to prevent expensive gradient re-paints
            const Positioned.fill(
              child: RepaintBoundary(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: RepaintBoundary(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 64,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              AppStrings.appName,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: AppStrings.email,
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            BlocBuilder<LoginCubit, LoginState>(
                              buildWhen: (prev, curr) =>
                                  prev.obscurePassword != curr.obscurePassword,
                              builder: (context, state) {
                                return TextField(
                                  controller: _passwordController,
                                  obscureText: state.obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _handleLogin(context),
                                  decoration: InputDecoration(
                                    labelText: AppStrings.password,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        state.obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () => context
                                          .read<LoginCubit>()
                                          .togglePasswordVisibility(),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            BlocBuilder<LoginCubit, LoginState>(
                              buildWhen: (prev, curr) =>
                                  prev.status != curr.status,
                              builder: (context, state) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed:
                                        state.status == BaseStatus.loading
                                        ? null
                                        : () => _handleLogin(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: state.status == BaseStatus.loading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            AppStrings.login,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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

  void _handleLogin(BuildContext context) {
    context.read<LoginCubit>().login(
      _emailController.text,
      _passwordController.text,
    );
  }
}
