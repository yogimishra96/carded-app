import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/app_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _loading       = false;
  bool _showPass      = false;
  bool _showConfirm   = false;
  String _resetToken  = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resetToken = ModalRoute.of(context)?.settings.arguments as String? ?? '';
  }

  @override
  void dispose() { _passCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final result = await AuthService.instance.resetPassword(_resetToken, _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password reset successfully!'),
          backgroundColor: AppColors.success));
      // Login screen pe bhejo, saari screens hata ke
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.message ?? 'Reset failed'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.lock_outline_rounded,
                    color: Color(0xFF6B21E8), size: 26)),
              const SizedBox(height: 20),

              const Text('Set New Password',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A), letterSpacing: -0.5)),
              const SizedBox(height: 8),
              const Text('Your new password must be\nat least 6 characters.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5)),
              const SizedBox(height: 32),

              AppTextField(
                label: 'New Password',
                hint: 'Min. 6 characters',
                controller: _passCtrl,
                obscureText: !_showPass,
                suffixIcon: IconButton(
                  icon: Icon(_showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20, color: AppColors.textHint),
                  onPressed: () => setState(() => _showPass = !_showPass)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password required';
                  if (v.length < 6) return 'Minimum 6 characters';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                label: 'Confirm Password',
                hint: 'Re-enter password',
                controller: _confirmCtrl,
                obscureText: !_showConfirm,
                suffixIcon: IconButton(
                  icon: Icon(_showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20, color: AppColors.textHint),
                  onPressed: () => setState(() => _showConfirm = !_showConfirm)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please confirm password';
                  if (v != _passCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B21E8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Reset Password',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}