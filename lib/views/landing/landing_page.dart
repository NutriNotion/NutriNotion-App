import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrinotion_app/const/custom_colors.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // Single image instead of a list
  final String _image = "assets/images/landing3.png";

  @override
  void initState() {
    super.initState();
    // No need for auto-scroll or page controller anymore
  }

  @override
  void dispose() {
    // No page controller to dispose anymore
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: double.infinity,
                        child: Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Image.asset(
                            _image,
                            height: 360,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      Positioned(
                        top: 100,
                        left: 24,
                        child: Transform.rotate(
                          angle: -0.2, // Rotate by approximately -11.5 degrees
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.8),
                                  Colors.white.withOpacity(0.6),

                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              spacing: 4,
                              children: [
                                Icon(Icons.restaurant_menu,
                                    color: const Color.fromARGB(255, 24, 24, 24), size: 16),
                                Text("NutriNotion",
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(255, 24, 24, 24),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 100,
                        right: 24,
                        child: Transform.rotate(
                          angle: 0.2, // Rotate by approximately -11.5 degrees
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.8),
                                  Colors.white.withOpacity(0.6),

                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              spacing: 4,
                              children: [
                                Icon(Icons.fastfood_outlined,
                                    color: const Color.fromARGB(255, 24, 24, 24), size: 16),
                                Text("Nutri Guide",
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(255, 24, 24, 24),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Container(
                    color: Colors.white,
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.lato(
                                  fontSize: 46,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 39, 39, 39).withAlpha(250),
                                  height: 1,
                                ),
                                children: [
                                  TextSpan(text: "Know", 
                                  style: TextStyle(color: primaryColor),
                                  ),
                                  TextSpan(
                                    text: " Your Meal,",
                                    // style: TextStyle(color: primaryColor),
                                  ),
                                  TextSpan(text: " Own ",
                                  style: TextStyle(color: primaryColor),
                                  ),
                                  TextSpan(
                                    text: "Your Health",
                                    // style: TextStyle(
                                    //   color: primaryColor,
                                    // ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              "NutriNotion is your personal nutrition assistant, helping you track your meals and manage your health effectively.",
                              style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.black.withAlpha(100),
                                  height: 1.5),
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 24.0),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text("Get Started".toUpperCase(), style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2
                                )),
                              ),
                            ),
                            SizedBox(height: 26),
                          ],
                        )
                      ],
                    ),
                  ),
                )),
          ],
        ));
  }
}
