import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/app_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _ctrl = TextEditingController();
  bool _submitted = false;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_ctrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    await AuthService.instance.forgotPassword(_ctrl.text.trim());
    if (!mounted) return;
    setState(() { _isLoading = false; _submitted = true; });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios, size: 20)),
              const SizedBox(height: 32),
              if (!_submitted) ...[
                const SectionHeader(title: 'Forgot Password?', subtitle: 'Enter your email or phone to reset your password'),
                const SizedBox(height: 36),
                AppTextField(label: 'Email or Phone', hint: 'Enter your email or phone', controller: _ctrl, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Send Reset Link'),
                ),
              ] else ...[
                const Spacer(flex: 2),
                Center(child: Column(children: [
                  Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), shape: BoxShape.circle),
                    child: const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 38)),
                  const SizedBox(height: 24),
                  const Text('Check your inbox', style: AppTextStyles.heading2),
                  const SizedBox(height: 10),
                  Text('We\'ve sent a reset link to\n${_ctrl.text}', style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
                  const SizedBox(height: 36),
                  ElevatedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('Back to Login')),
                ])),
                const Spacer(flex: 3),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
