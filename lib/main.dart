import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_cards_screen.dart';
import 'screens/template_selection_screen.dart';
import 'screens/create_card_details_screen.dart';
import 'screens/card_preview_screen.dart';
import 'screens/card_nickname_screen.dart';
import 'screens/share_card_screen.dart';
import 'screens/scan_card_screen.dart';
import 'screens/collected_cards_screen.dart';
import 'screens/collected_card_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/verify_otp_screen.dart';
import 'screens/reset_password_screen.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const CardedApp());
}

class CardedApp extends StatelessWidget {
  const CardedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carded',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const SplashScreen(),
        '/login': (ctx) => const LoginScreen(),
        '/register': (ctx) => const RegisterScreen(),
        '/forgot-password': (ctx) => const ForgotPasswordScreen(),
        '/verify-otp':      (_) => const VerifyOtpScreen(),
        '/reset-password':  (_) => const ResetPasswordScreen(),
        '/home': (ctx) => const HomeScreen(),
        '/my-cards': (ctx) => const MyCardsScreen(),
        '/create-template': (ctx) => const TemplateSelectionScreen(),
        '/create-details': (ctx) => const CreateCardDetailsScreen(),
        '/card-preview': (ctx) => const CardPreviewScreen(),
        '/card-nickname': (ctx) => const CardNicknameScreen(),
        '/share': (ctx) => const ShareCardScreen(),
        '/scan': (ctx) => const ScanCardScreen(),
        '/collected-cards': (ctx) => const CollectedCardsScreen(),
        '/collected-card-detail': (ctx) => const CollectedCardDetailScreen(),
        '/settings': (ctx) => const SettingsScreen(),
      },
    );
  }
}
