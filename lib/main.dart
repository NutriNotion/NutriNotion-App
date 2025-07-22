import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrinotion_app/firebase_options.dart';
import 'package:nutrinotion_app/views/auth/login_page.dart';
import 'package:nutrinotion_app/views/landing/landing_page.dart';
import 'package:nutrinotion_app/views/auth/signup.dart';
import 'package:nutrinotion_app/views/home/home_page.dart';
import 'package:nutrinotion_app/backend/providers/auth_provider.dart';
import 'package:nutrinotion_app/backend/providers/user_provider.dart';
import 'package:nutrinotion_app/backend/providers/nutrition_provider.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Continue running the app even if Firebase fails to initialize
    // You can show a message to the user or handle this gracefully
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
      ],
      child: MaterialApp(
        title: 'NutriNotion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const LandingPage(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/signup': (context) => const SignUpPage(),
        },
      ),
    );
  }
}

// Placeholder home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
          ],
        ),
      ),
    );
  }
}