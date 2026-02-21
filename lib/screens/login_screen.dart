import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await AuthService.instance.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Login failed'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios, size: 20)),
                const SizedBox(height: 32),
                const SectionHeader(title: 'Welcome back', subtitle: 'Sign in to continue to Carded'),
                const SizedBox(height: 36),
                AppTextField(label: 'Email or Phone', hint: 'Enter your email or phone', controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                AppTextField(label: 'Password', hint: 'Enter your password', controller: _passCtrl,
                  obscureText: _obscurePassword, validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textSecondary),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () => Navigator.pushNamed(context, '/forgot-password'), child: const Text('Forgot Password?'))),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Login'),
                ),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Don't have an account? ", style: AppTextStyles.bodySecondary),
                  TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/register'), child: const Text('Register')),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
