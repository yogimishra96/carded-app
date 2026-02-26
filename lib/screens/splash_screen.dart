import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _logoAnim;
  late Animation<double> _textAnim;
  late Animation<double> _btnAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    _logoAnim = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutBack));

    _textAnim = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.40, 0.70, curve: Curves.easeOut));

    _btnAnim = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.65, 0.95, curve: Curves.easeOut));

    _ctrl.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    final isLoggedIn = await AuthService.instance.isLoggedIn();
    if (!mounted) return;
    if (isLoggedIn) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      // Pure white — koi tint nahi
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [

              SizedBox(height: h * 0.14),

              // ── Logo ──────────────────────────────────────────
              Opacity(
                opacity: _logoAnim.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.65 + (_logoAnim.value * 0.35),
                  child: Image.asset(
                    'assets/icon/logo.png',
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Tagline ───────────────────────────────────────
              Opacity(
                opacity: _textAnim.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - _textAnim.value)),
                  child: const Text(
                    'Your digital visiting card',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ── Buttons ───────────────────────────────────────
              Opacity(
                opacity: _btnAnim.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 24 * (1 - _btnAnim.value)),
                  child: Column(children: [

                    // Login — solid purple
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B21E8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Login',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Create Account — outlined
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B21E8),
                          side: const BorderSide(color: Color(0xFF6B21E8), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Create Account',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Footer
                    const Text(
                      'Digital cards. Zero paper.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), letterSpacing: 0.4),
                    ),

                    const SizedBox(height: 12),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}