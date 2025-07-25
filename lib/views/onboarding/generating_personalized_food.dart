import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nutrinotion_app/const/custom_colors.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import '../../backend/providers/ai_provider.dart';
import '../../backend/providers/auth_provider.dart';
import '../../backend/providers/firestore_provider.dart';
import '../../backend/providers/personalized_food_provider.dart';
import '../../backend/providers/user_provider.dart';

class GeneratingPersonalizedFood extends StatefulWidget {
  const GeneratingPersonalizedFood({super.key});

  @override
  State<GeneratingPersonalizedFood> createState() => _GeneratingPersonalizedFoodState();
}

class _GeneratingPersonalizedFoodState extends State<GeneratingPersonalizedFood> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final aiProvider = Provider.of<AiProvider>(context, listen: false);
      final firestoreProvider =
          Provider.of<FirestoreProvider>(context, listen: false);
      final personalizedFoodProvider =
          Provider.of<PersonalizedFoodProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Load user data including calorie target
      if (authProvider.userId != null) {
        await userProvider.loadFromFirestore(authProvider.userId!);
      }

      // Get personalized food data and calories
      await personalizedFoodProvider
          .getPersonalizedFood(authProvider.userId ?? '');

      // Fetch today's calories
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await personalizedFoodProvider.getTotalCaloriesForDate(
          authProvider.userId ?? '', today);

      final res = await aiProvider.getUserDetails(authProvider.userId ?? '');
      final menu = await aiProvider.getMenuDetails();

      if (res != null && menu.isNotEmpty && authProvider.userId != null) {
        final check = await firestoreProvider
            .checkForPersonalizedFood(authProvider.userId ?? '');
        print("Check for personalized food: $check");
        if (check == false) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
        final aiData = aiProvider.formatDataForAI(res, menu);
        print("AI Data: $aiData");
        final recommendations =
            await aiProvider.generateRecommendations(aiData);
        print("Recommendations: $recommendations");
        await firestoreProvider.updatePersonalizedMenu(
            authProvider.userId ?? '', recommendations);
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        print("Failed to fetch user details or menu.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [     
              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animation container with background
                  Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: RiveAnimation.asset('assets/animations/generating.riv'),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Main title with gradient effect
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Text(
                        //   "🍳 Cooking Up Magic!",
                        //   style: GoogleFonts.lato(
                        //     fontSize: 28,
                        //     color: primaryColor,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
                        // const SizedBox(height: 12),
                        Text(
                          "Your Personalized Menu",
                          style: GoogleFonts.lato(
                            fontSize: 24,
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "is Being Prepared",
                          style: GoogleFonts.lato(
                            fontSize: 24,
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Subtitle with engaging copy
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Our nutrition experts are crafting a delicious meal plan tailored just for you, based on your preferences and health goals!",
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              
              // Bottom section with progress and tips
              Column(
                children: [
                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 600 + (index * 200)),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Fun facts container
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Did you know?",
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Personalized nutrition can improve your energy levels by up to 40%!",
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Loading text
                  Text(
                    "This usually takes just a few moments...",
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
