import 'package:flutter/material.dart';
import 'package:nutrinotion_app/backend/providers/personalized_food_provider.dart';
import 'package:nutrinotion_app/views/onboarding/diet_preferences_page.dart';
import 'package:nutrinotion_app/views/onboarding/generating_personalized_food.dart';
import 'package:nutrinotion_app/views/onboarding/height_weight_page.dart';
import 'package:nutrinotion_app/views/onboarding/splashscreen.dart';
import 'package:provider/provider.dart';
import 'package:nutrinotion_app/firebase_options.dart';
import 'package:nutrinotion_app/views/auth/login_page.dart';
import 'package:nutrinotion_app/views/landing/landing_page.dart';
import 'package:nutrinotion_app/views/auth/signup.dart';
import 'package:nutrinotion_app/views/home/home_page.dart';
import 'package:nutrinotion_app/backend/providers/auth_provider.dart';
import 'package:nutrinotion_app/backend/providers/nutrition_provider.dart';
import 'package:nutrinotion_app/const/page_transitions.dart';

import 'package:firebase_core/firebase_core.dart';

import 'backend/providers/ai_provider.dart';
import 'backend/providers/firestore_provider.dart';
import 'backend/providers/mess_provider.dart';
import 'backend/providers/user_provider.dart';
import 'views/onboarding/lifestyle_goal_page.dart';

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
        ChangeNotifierProvider(create: (_) => FirestoreProvider()),
        ChangeNotifierProvider(create: (_) => MessProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => PersonalizedFoodProvider())
      ],
      child: MaterialApp(
        title: 'NutriNotion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const GeneratingPersonalizedFood(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return FadePageRoute(child: const LoginPage(), durationMs: 500);
            case '/home':
              return FadePageRoute(child: const HomePage(), durationMs: 600);
            case '/signup':
              return FadePageRoute(child: const SignUpPage(), durationMs: 400);
            case '/diet-preferences':
              return FadePageRoute(child: const DietPreferencesPage(), durationMs: 500);
            case '/height-weight':
              return FadePageRoute(child: const HeightWeightPage(), durationMs: 500);
            case '/lifestyle-goal':
              return FadePageRoute(child: const LifestyleGoalPage(), durationMs: 500);
            case 'generating-personalized-menu' :
              return FadePageRoute(child: const GeneratingPersonalizedFood(), durationMs: 500);
            default:
              return FadePageRoute(child: const LandingPage(), durationMs: 300);
          }
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