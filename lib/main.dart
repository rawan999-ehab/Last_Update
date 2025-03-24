import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // تأكد من استيراد حزمة provider
import 'screens/Auth/register_screen.dart';
import 'screens/splash_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
// Auth
import 'screens/Auth/login_screen.dart';
import 'screens/Auth/forgot_password_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Features
import 'screens/Features/main_screen.dart';
// Company
import 'Company Screens/Home_Screen.dart';
// Admin
import 'Adminscreens/Features/Admin-MS.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/Auth/auth_provider.dart'; // استيراد AuthProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("a7907370-789c-4b08-b75d-88a68dd2490a"); // Replace with your OneSignal App ID
  OneSignal.Notifications.requestPermission(true);

  await dotenv.load(fileName: "dotenv.get"); // Load dotenv.get file

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // إضافة AuthProvider
        // يمكنك إضافة المزيد من الـ Providers هنا
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => SplashScreen(),
        MainScreen.routeName: (_) => MainScreen(),
        Adminms.routeName: (_) => Adminms(),
        // Auth
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => RegisterScreen(),
        ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
        Home_Screen.routeName: (_) => Home_Screen(),
      },
    );
  }
}