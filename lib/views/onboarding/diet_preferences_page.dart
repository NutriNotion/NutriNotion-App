import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutrinotion_app/backend/providers/user_provider.dart';
import 'package:nutrinotion_app/const/custom_colors.dart';

class DietPreferencesPage extends StatefulWidget {
  const DietPreferencesPage({super.key});

  @override
  State<DietPreferencesPage> createState() => _DietPreferencesPageState();
}

class _DietPreferencesPageState extends State<DietPreferencesPage> {
  String _selectedDietType = '';
  List<String> _selectedAllergies = [];
  List<String> _dislikedFoods = [];
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _dislikedFoodController = TextEditingController();

  final List<Map<String, dynamic>> _dietTypes = [
    {
      'title': 'Vegetarian',
      'subtitle': 'No meat, but includes dairy and eggs',
      'icon': Icons.eco,
      'value': 'vegetarian',
    },
    {
      'title': 'Non-Vegetarian',
      'subtitle': 'Includes all types of food',
      'icon': Icons.restaurant,
      'value': 'non_vegetarian',
    },
    {
      'title': 'Vegan',
      'subtitle': 'Plant-based diet only',
      'icon': Icons.local_florist,
      'value': 'vegan',
    },
  ];

  @override
  void dispose() {
    _allergyController.dispose();
    _dislikedFoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    RichText(
                      text: TextSpan(
                        text: 'Diet',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: '\nPreferences',
                            style: GoogleFonts.lato(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Help us personalize your nutrition suggestions based on your dietary preferences and restrictions",
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.start,
                    ),

                    const SizedBox(height: 24),

                    // Dietary Type Section
                    Text(
                      'Dietary Type',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Diet Type Options
                    ...(_dietTypes.map((diet) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildDietOptionCard(
                            title: diet['title'],
                            subtitle: diet['subtitle'],
                            icon: diet['icon'],
                            value: diet['value'],
                            isSelected: _selectedDietType == diet['value'],
                            onTap: () {
                              setState(() {
                                _selectedDietType = diet['value'];
                              });
                            },
                          ),
                        ))),

                    const SizedBox(height: 32),

                    // Allergies Section
                    Row(
                      children: [
                        Text(
                          'Allergies',
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Optional',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildAllergiesSection(),

                    const SizedBox(height: 32),

                    // Disliked Foods Section
                    Row(
                      children: [
                        Text(
                          'Disliked Foods',
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Optional',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildDislikedFoodsSection(),

                    const SizedBox(height: 24),

                    // Continue Button
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return Container(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_selectedDietType.isNotEmpty &&
                                    !userProvider.isLoading)
                                ? _saveAndContinue
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: userProvider.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Complete Profile',
                                    style: GoogleFonts.lato(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isSelected ? 0.2 : 0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? primaryColor : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergiesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _allergyController,
                  decoration: InputDecoration(
                    hintText: 'Add an allergy...',
                    hintStyle: GoogleFonts.lato(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: GoogleFonts.lato(fontSize: 14),
                  onSubmitted: _addAllergy,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _addAllergy(_allergyController.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          if (_selectedAllergies.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedAllergies.map((allergy) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        allergy,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAllergies.remove(allergy);
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDislikedFoodsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dislikedFoodController,
                  decoration: InputDecoration(
                    hintText: 'Add a food you dislike...',
                    hintStyle: GoogleFonts.lato(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: GoogleFonts.lato(fontSize: 14),
                  onSubmitted: _addDislikedFood,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _addDislikedFood(_dislikedFoodController.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          if (_dislikedFoods.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dislikedFoods.map((food) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        food,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _dislikedFoods.remove(food);
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _addDislikedFood(String food) {
    if (food.trim().isNotEmpty && !_dislikedFoods.contains(food.trim())) {
      setState(() {
        _dislikedFoods.add(food.trim());
        _dislikedFoodController.clear();
      });
    }
  }

  void _addAllergy(String allergy) {
    if (allergy.trim().isNotEmpty &&
        !_selectedAllergies.contains(allergy.trim())) {
      setState(() {
        _selectedAllergies.add(allergy.trim());
        _allergyController.clear();
      });
    }
  }

  double _calculateCalories(String gender, int weight, double height, int age,
      String activityLevel, String fitnessGoal) {
    double bmr = bmrCalculate(gender, weight, height, age);
    double activity = activityFactor(activityLevel);
    double maintenanceCalories = bmr * activity;

    // Adjust calories based on fitness goal
    int goalAdjustment = 0;
    switch (fitnessGoal) {
      case 'Gain Weight':
        goalAdjustment = 250; // Add 250 calories for weight gain
        break;
      case 'Lose Weight':
        goalAdjustment = -250; // Subtract 250 calories for weight loss
        break;
      case 'Maintain Fitness':
        goalAdjustment = 100; // Add 100 calories for maintenance
        break;
      default:
        goalAdjustment = 0; // No adjustment if goal is not specified
    }

    return maintenanceCalories + goalAdjustment;
  }

  double bmrCalculate(String gender, int weight, double height, int age) {
    if (gender.toLowerCase() == "male") {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  double activityFactor(String activity) {
    switch (activity) {
      case 'Sedentary':
        return 1.2;
      case 'Moderate':
        return 1.55;
      case 'Active':
        return 1.725;
      default:
        return 1.2; // Default to sedentary if unknown
    }
  }

  void _saveAndContinue() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Save diet preferences to user provider
    userProvider.updateDietInfo(
      dietType: _selectedDietType,
      allergies: _selectedAllergies,
      dislikedFoods: _dislikedFoods,
    );

    // Calculate calorie target based on user data
    final user = userProvider.user;
    double calorieTarget = _calculateCalories(
      user.gender ?? '',
      user.weight ?? 0,
      user.height ?? 0,
      user.age ?? 0,
      user.activityLevel ?? '',
      user.fitnessGoal ?? 'Maintain Fitness',
    );

    // Update user model with calorie target
    userProvider.updateCalorieTarget(calorieTarget.toInt());

    try {
      // Save to Firestore and mark profile as complete
      final success = await userProvider.completeProfile();

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile completed and saved successfully!'),
            backgroundColor: primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to home page
        Navigator.pushReplacementNamed(
            context, '/generating-personalized-menu');
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Handle any unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
