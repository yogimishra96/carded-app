import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});
  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _ctlrs =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
  }

  @override
  void dispose() {
    for (final c in _ctlrs) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _otp => _ctlrs.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter the complete 6-digit code'),
          backgroundColor: AppColors.error));
      return;
    }
    setState(() => _loading = true);
    final result = await AuthService.instance.verifyOtp(_email, _otp);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success && result.resetToken != null) {
      Navigator.pushNamed(context, '/reset-password', arguments: result.resetToken);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.message ?? 'Invalid code'),
          backgroundColor: AppColors.error));
      for (final c in _ctlrs) c.clear();
      _nodes[0].requestFocus();
    }
  }

  Future<void> _resend() async {
    await AuthService.instance.forgotPassword(_email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New code sent to your email.')));
  }

  void _onDigitInput(String val, int idx) {
    if (val.length == 1 && idx < 5) _nodes[idx + 1].requestFocus();
    if (val.isEmpty && idx > 0) _nodes[idx - 1].requestFocus();
    if (_otp.length == 6) _verify();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ← KEY FIX: scroll up when keyboard opens, no overflow
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // ← keyboard pushes content up, not overflow
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            28, 16, 28,
            MediaQuery.of(context).viewInsets.bottom + 24, // ← extra space above keyboard
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.mark_email_read_outlined,
                  color: Color(0xFF6B21E8), size: 26)),
            const SizedBox(height: 20),

            const Text('Check your email',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A), letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text('We sent a 6-digit code to\n$_email',
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5)),

            const SizedBox(height: 36),

            // ── 6 OTP boxes ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) => SizedBox(
                width: 46, height: 56,
                child: TextFormField(
                  controller: _ctlrs[i],
                  focusNode:  _nodes[i],
                  textAlign:  TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6B21E8), width: 2)),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFF),
                  ),
                  onChanged: (v) => _onDigitInput(v, i),
                ),
              )),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B21E8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Verify Code',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 20),

            Center(child: TextButton(
              onPressed: _resend,
              child: const Text("Didn't receive it? Resend code",
              style: TextStyle(color: Color(0xFF6B21E8), fontWeight: FontWeight.w600)),
            )),

          ]),
        ),
      ),
    );
  }
}