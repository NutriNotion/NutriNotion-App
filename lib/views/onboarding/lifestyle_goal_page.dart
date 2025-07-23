import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutrinotion_app/backend/providers/user_provider.dart';
import 'package:nutrinotion_app/const/custom_colors.dart';

class LifestyleGoalPage extends StatefulWidget {
  const LifestyleGoalPage({super.key});

  @override
  State<LifestyleGoalPage> createState() => _LifestyleGoalPageState();
}

class _LifestyleGoalPageState extends State<LifestyleGoalPage> {
  String _selectedActivityLevel = '';
  String _selectedGoal = '';

  final List<Map<String, dynamic>> _activityLevels = [
    {
      'title': 'Sedentary',
      'subtitle': 'Mostly sitting, minimal exercise',
      'icon': Icons.chair,
      'value': 'sedentary',
    },
    {
      'title': 'Moderate',
      'subtitle': 'Some walking and light exercise',
      'icon': Icons.directions_walk,
      'value': 'moderate',
    },
    {
      'title': 'Active',
      'subtitle': 'Regular workouts and activities',
      'icon': Icons.fitness_center,
      'value': 'active',
    },
  ];

  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Gain Weight',
      'subtitle': 'Build muscle and increase mass',
      'icon': Icons.trending_up,
      'value': 'gain_weight',
    },
    {
      'title': 'Lose Weight',
      'subtitle': 'Burn fat and reduce weight',
      'icon': Icons.trending_down,
      'value': 'lose_weight',
    },
    {
      'title': 'Maintain Fitness',
      'subtitle': 'Stay healthy and fit',
      'icon': Icons.balance,
      'value': 'maintain_fitness',
    },
  ];

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
                        text: 'Your Lifestyle',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: '\n& Goals',
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
                      "Help us understand your activity level and fitness goals to personalize your nutrition plan",
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.start,
                    ),

                    const SizedBox(height: 24),

                    // Activity Level Section
                    Text(
                      'Activity Level',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Activity Level Options
                    ...(_activityLevels.map((activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionCard(
                        title: activity['title'],
                        subtitle: activity['subtitle'],
                        icon: activity['icon'],
                        value: activity['value'],
                        isSelected: _selectedActivityLevel == activity['value'],
                        onTap: () {
                          setState(() {
                            _selectedActivityLevel = activity['value'];
                          });
                        },
                      ),
                    ))),

                    const SizedBox(height: 32),

                    // Goals Section
                    Text(
                      'Fitness Goal',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Goal Options
                    ...(_goals.map((goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionCard(
                        title: goal['title'],
                        subtitle: goal['subtitle'],
                        icon: goal['icon'],
                        value: goal['value'],
                        isSelected: _selectedGoal == goal['value'],
                        onTap: () {
                          setState(() {
                            _selectedGoal = goal['value'];
                          });
                        },
                      ),
                    ))),

                    const SizedBox(height: 24),

                    // Continue Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_selectedActivityLevel.isNotEmpty && _selectedGoal.isNotEmpty) 
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
                        child: Text(
                          'Continue',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
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

  Widget _buildOptionCard({
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

  void _saveAndContinue() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Save lifestyle and goals to user provider
    userProvider.updateLifestyleInfo(
      activityLevel: _selectedActivityLevel,
      fitnessGoal: _selectedGoal,
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lifestyle & Goals saved successfully!'),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to next step (you can customize this)
    Navigator.pushReplacementNamed(context, '/diet-preferences');
  }
}