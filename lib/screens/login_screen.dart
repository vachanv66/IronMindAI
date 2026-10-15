import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String? error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => error = 'Please enter both email and password.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final result = await AuthService.login(email: email, password: password);
    if (!mounted) return;

    if (result.success && result.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DashboardScreen(goal: result.user!.goal, level: result.user!.fitnessLevel),
        ),
      );
    } else {
      setState(() {
        loading = false;
        error = result.errorMessage ?? 'Invalid email or password. Please try again.';
      });
    }
  }

  void _showResetPasswordDialog() {
    final resetEmailCtrl = TextEditingController(text: emailController.text.trim());
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    String? modalError;
    bool modalLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reset Your Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter your account email and choose a new secure password.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: resetEmailCtrl,
                    label: 'Email address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: newPassCtrl,
                    label: 'New Password',
                    prefixIcon: Icons.lock_reset_outlined,
                    obscureText: true,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: confirmPassCtrl,
                    label: 'Confirm New Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  if (modalError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      modalError!,
                      style: const TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Confirm Reset',
                    isLoading: modalLoading,
                    onPressed: () async {
                      final email = resetEmailCtrl.text.trim();
                      final pass = newPassCtrl.text.trim();
                      final confirm = confirmPassCtrl.text.trim();

                      if (email.isEmpty || pass.isEmpty) {
                        setModalState(() => modalError = 'Please fill in all fields.');
                        return;
                      }
                      if (pass.length < 6) {
                        setModalState(() => modalError = 'Password must be at least 6 characters.');
                        return;
                      }
                      if (pass != confirm) {
                        setModalState(() => modalError = 'Passwords do not match.');
                        return;
                      }

                      setModalState(() {
                        modalLoading = true;
                        modalError = null;
                      });

                      final nav = Navigator.of(ctx);
                      final messenger = ScaffoldMessenger.of(context);

                      final res = await AuthService.resetPassword(email: email, newPassword: pass);
                      nav.pop();

                      if (!mounted) return;

                      if (res.success) {
                        emailController.text = email;
                        passwordController.text = pass;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Password reset successfully! You can now sign in.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      } else {
                        setState(() {
                          error = res.errorMessage ?? 'Password reset failed.';
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in to IronMind')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to access your workout plans and pose analytics.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: emailController,
                label: 'Email address',
                hint: 'user@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: passwordController,
                label: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showResetPasswordDialog,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          error!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              CustomButton(
                text: 'Sign In',
                isLoading: loading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
