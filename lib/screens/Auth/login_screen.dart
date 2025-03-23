import 'package:flutter/material.dart';
import '../../services/snackbar_service.dart';
import 'auth_service.dart';
import 'input_decoration.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/LoginScreen";
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final SnackBarService _snackBarService = SnackBarService();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08, vertical: screenHeight * 0.05),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: screenHeight * 0.1),
                    Image.asset(
                      'assets/images/logo1.jpeg',
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.1,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        color: Color(0xFF196AB2),
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecorationService.buildInputDecoration("Email", Icons.email),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecorationService.buildInputDecoration("Password", Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF196AB3),
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.2, vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        await _authService.loginWithEmailAndPassword(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          context,
                        );
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "I don't have an account! ",
                          style: TextStyle(color: Colors.black54, fontSize: screenWidth * 0.04),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, RegisterScreen.routeName);
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(color: Color(0xFF196AB3), fontSize: screenWidth * 0.04),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Or",
                      style: TextStyle(
                        color: Color(0xFF196AB3),
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    OutlinedButton(
                      onPressed: () async {
                        await _authService.signInWithGoogle(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015, horizontal: screenWidth * 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: BorderSide(color: Colors.blue, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/google_icon.jpeg",
                            height: 24,
                            width: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Continue with Google",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: screenWidth * 0.042,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}