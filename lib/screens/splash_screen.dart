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
  late Animation<double> _scaleFade; 
  late Animation<double> _textFade; 
  late Animation<double> _btnFade; 

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    _scaleFade = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack));

    _textFade = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut));

    _btnFade = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.60, 0.90, curve: Curves.easeOut));

    _ctrl.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    final isLoggedIn = await AuthService.instance.isLoggedIn();
    if (!mounted) return;
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Original Colors (Deep Blue to Purple)
    const Color primaryColor = Color(0xFF6B21E8);
    const Color accentColor = Color(0xFFB45EF5);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Stack(children: [
          
          // Subtle radial background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.white,
                  primaryColor.withOpacity(0.06),
                ],
              ),
            ),
          ),

          // Decorative Circles
          Positioned(
            left: -60, top: -60,
            child: Opacity(
              opacity: _btnFade.value * 0.4,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.08),
                ),
              ),
            ),
          ),


          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(children: [
                SizedBox(height: size.height * 0.18),

                // ── LOGO SECTION ──
                Transform.scale(
                  scale: 0.7 + (_scaleFade.value * 0.3),
                  child: Opacity(
                    opacity: _scaleFade.value.clamp(0.0, 1.0),
                    child: Image.asset(
                      'assets/icon/logo.png',
                      width: 280, // Size bada rakha hai
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tagline
                Opacity(
                  opacity: _textFade.value.clamp(0.0, 1.0),
                  child: Text(
                    'Your digital visiting card',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const Spacer(),

                // Buttons Section
                Opacity(
                  opacity: _btnFade.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _btnFade.value)),
                    child: Column(children: [
                      
                      // Login Button with Gradient
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [primaryColor, accentColor],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Register Button (Outlined style)
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: primaryColor.withOpacity(0.3), 
                                width: 1.5
                            ),
                            color: primaryColor.withOpacity(0.05),
                          ),
                          child: const Center(
                            child: Text('Create Account',
                                style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),
                      
                      Text('Digital cards. Zero paper.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.3,
                        )),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}