import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/app_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await AuthService.instance.register(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Registration failed'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

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
                const SectionHeader(title: 'Create Account', subtitle: 'Join Carded and go digital'),
                const SizedBox(height: 36),
                AppTextField(label: 'Full Name', hint: 'e.g. John Doe', controller: _nameCtrl, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                AppTextField(label: 'Email', hint: 'your@email.com', controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                  validator: (v) { if (v == null || v.isEmpty) return 'Required'; if (!v.contains('@')) return 'Invalid email'; return null; }),
                const SizedBox(height: 16),
                AppTextField(label: 'Phone', hint: '+91 98765 43210', controller: _phoneCtrl, keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                AppTextField(label: 'Password', hint: 'Min 6 characters', controller: _passCtrl, obscureText: _obscurePassword,
                  validator: (v) { if (v == null || v.isEmpty) return 'Required'; if (v.length < 6) return 'Min 6 characters'; return null; },
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textSecondary),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Create Account'),
                ),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Already have an account? ', style: AppTextStyles.bodySecondary),
                  TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('Login')),
                ]),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
