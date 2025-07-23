import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutrinotion_app/backend/providers/auth_provider.dart';
import 'package:nutrinotion_app/const/custom_colors.dart';
import 'package:nutrinotion_app/const/page_transitions.dart';
import 'package:nutrinotion_app/views/auth/signup.dart';
import 'package:nutrinotion_app/views/home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _isPasswordVisible = false;
  AnimationController? _rotationController;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 140), // slower, smoother
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // Basic validation
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }
    
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
      return;
    }

    // Email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.signIn(_emailController.text.trim(), _passwordController.text.trim()).then((success) {
      if (success) {
        context.pushReplacementFade(const HomePage(), duration: 600);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              primaryColor.withOpacity(0.8),
              primaryColor.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
        child: Stack(
          children: [
            // Rotating background image (fixed at the top)
            Positioned(
              top: -200,
              left: 0,
              right: 0,
              child: _rotationController != null
                  ? AnimatedBuilder(
                      animation: _rotationController!,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController!.value * 2 * math.pi,
                          child: child,
                        );
                      },
                      child: Image.asset(
                        "assets/images/landing3.png",
                        height: MediaQuery.of(context).size.height / 2,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      "assets/images/landing3.png",
                      height: MediaQuery.of(context).size.height / 2,
                      fit: BoxFit.cover,
                    ),
            ),

            // Login Form
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const Spacer(),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 40),
                                  Text("Login",
                                      style: GoogleFonts.lato(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      )),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Welcome back! Please login to your account.",
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: const Color.fromARGB(137, 51, 51, 51),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 40),

                                  // Email field
                                  TextField(
                                    controller: _emailController,
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "Email",
                                      labelStyle: GoogleFonts.lato(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey.shade900),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Password field
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      labelStyle: GoogleFonts.lato(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(_isPasswordVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey.shade900),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Login button
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return GestureDetector(
                                        onTap: authProvider.isLoading ? null : _login,
                                        child: Container(
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0, horizontal: 24.0),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          child: authProvider.isLoading
                                              ? const SizedBox(
                                                  width: 23,
                                                  height: 23,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : Text("LOGIN",
                                                  style: GoogleFonts.lato(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.2,
                                                  )),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // OR Divider
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Divider(
                                        thickness: 1,
                                        color: Colors.grey.shade300,
                                      )),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          "OR",
                                          style: GoogleFonts.lato(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Divider(
                                        thickness: 1,
                                        color: Colors.grey.shade300,
                                      )),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Sign up link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context.pushFade(const SignUpPage(), duration: 400);
                                        },
                                        child: Text(" Sign Up",
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
