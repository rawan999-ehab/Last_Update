import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// Firebase config
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// Auth
import 'Student Screens/Auth/auth_provider.dart';
import 'Student Screens/Auth/login_screen.dart';
import 'Student Screens/Auth/register_screen.dart';
import 'Student Screens/Auth/forgot_password_screen.dart';

// Screens
import 'Student Screens/splash_screen.dart';
import 'Student Screens/Features/main_student.dart';
import 'Admin screens/Features/Admin-MS.dart';
// ❌ شيل import بتاع MainCompany من الراوتس

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://xafztwdrytnggitdbioc.supabase.co', // 🔁 استبدل بالرابط من Supabase
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhZnp0d2RyeXRuZ2dpdGRiaW9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5MDU5ODgsImV4cCI6MjA2MDQ4MTk4OH0.Xn0b_ArBP2-sSyS9WBGHKlVUEMHMPt7FtCy5XBPtehk', // 🔁 استبدل بالمفتاح من Supabase
  );


  // Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("a7907370-789c-4b08-b75d-88a68dd2490a");
  OneSignal.Notifications.requestPermission(true);

  // Load .env variables
  await dotenv.load(fileName: "dotenv.get");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => SplashScreen(),
        MainScreen.routeName: (_) => MainScreen(),
        Adminms.routeName: (_) => Adminms(),

        // Auth Screens
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => RegisterScreen(),
        ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),

        // ❌ متضيفش MainCompany هنا لأنه محتاج companyId
      },
    );
  }
}
