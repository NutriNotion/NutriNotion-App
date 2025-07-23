import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutrinotion_app/backend/providers/user_provider.dart';
import 'package:nutrinotion_app/const/custom_colors.dart';

class HeightWeightPage extends StatefulWidget {
  const HeightWeightPage({super.key});

  @override
  State<HeightWeightPage> createState() => _HeightWeightPageState();
}

class _HeightWeightPageState extends State<HeightWeightPage> {
  double _selectedHeight = 170.0; // in cm
  int _selectedWeight = 70; // in kg
  int _selectedAge = 22;
  String _selectedGender = 'Male';
  String _heightUnit = 'cm';
  String _weightUnit = 'kg';
  
  final List<String> _genderOptions = ['Male', 'Female'];

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
                        text: 'Complete Your',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: '\nProfile',
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

                    Text("Let's gather some basic information to personalize your experience",
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.start,
                    ),

                    const SizedBox(height: 8),

                    // Age Selector
                    _buildAgeCard(),

                    const SizedBox(height: 8),

                    // Gender Selector
                    _buildGenderCard(),

                    const SizedBox(height: 8),

                    // Height Selector
                    _buildHeightMeasurementCard(
                      title: 'Height',
                      icon: Icons.height,
                      value: _selectedHeight,
                      unit: _heightUnit,
                      minValue: 100.0,
                      maxValue: 250.0,
                      onChanged: (value) {
                        setState(() {
                          _selectedHeight = value;
                        });
                      },
                      unitOptions: ['cm', 'ft'],
                      onUnitChanged: (unit) {
                        setState(() {
                          if (unit == 'ft' && _heightUnit == 'cm') {
                            // Convert cm to feet (1 cm = 0.0328084 ft)
                            _selectedHeight = _selectedHeight * 0.0328084;
                          } else if (unit == 'cm' && _heightUnit == 'ft') {
                            // Convert feet to cm (1 ft = 30.48 cm)
                            _selectedHeight = _selectedHeight * 30.48;
                          }
                          _heightUnit = unit;
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    // Weight Selector
                    _buildWeightMeasurementCard(
                      title: 'Weight',
                      icon: Icons.monitor_weight,
                      value: _selectedWeight,
                      unit: _weightUnit,
                      minValue: 30,
                      maxValue: 200,
                      onChanged: (value) {
                        setState(() {
                          _selectedWeight = value;
                        });
                      },
                      unitOptions: ['kg', 'lbs'],
                      onUnitChanged: (unit) {
                        setState(() {
                          if (unit == 'lbs' && _weightUnit == 'kg') {
                            _selectedWeight = (_selectedWeight * 2.205).round();
                          } else if (unit == 'kg' && _weightUnit == 'lbs') {
                            _selectedWeight = (_selectedWeight / 2.205).round();
                          }
                          _weightUnit = unit;
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    // BMI Display
                    _buildBMICard(),

                    const SizedBox(height: 12),

                    // Continue Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
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

  Widget _buildHeightMeasurementCard({
    required String title,
    required IconData icon,
    required double value,
    required String unit,
    required double minValue,
    required double maxValue,
    required Function(double) onChanged,
    required List<String> unitOptions,
    required Function(String) onUnitChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Unit Selector - Toggle Buttons
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: unitOptions.map((unitOption) {
                    final isSelected = unit == unitOption;
                    return GestureDetector(
                      onTap: () => onUnitChanged(unitOption),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unitOption,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horizontal Numeric Selector for Height
          Container(
            height: 60,
            child: _buildHorizontalHeightSelector(
              value: value,
              minValue: minValue,
              maxValue: maxValue,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightMeasurementCard({
    required String title,
    required IconData icon,
    required int value,
    required String unit,
    required int minValue,
    required int maxValue,
    required Function(int) onChanged,
    required List<String> unitOptions,
    required Function(String) onUnitChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(60),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Unit Selector - Toggle Buttons
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: unitOptions.map((unitOption) {
                    final isSelected = unit == unitOption;
                    return GestureDetector(
                      onTap: () => onUnitChanged(unitOption),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unitOption,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horizontal Numeric Selector for Weight
          Container(
            height: 60,
            child: _buildHorizontalWeightSelector(
              value: value,
              minValue: minValue,
              maxValue: maxValue,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalHeightSelector({
    required double value,
    required double minValue,
    required double maxValue,
    required Function(double) onChanged,
  }) {
    // Adjust min/max values and increment based on unit
    double adjustedMin, adjustedMax, increment;
    List<String> heightValues = [];
    List<double> actualValues = [];
    
    if (_heightUnit == 'cm') {
      adjustedMin = 100.0;
      adjustedMax = 250.0;
      increment = 0.5;
      
      // Create cm values
      for (double i = adjustedMin; i <= adjustedMax; i += increment) {
        actualValues.add(i);
        heightValues.add(i % 1 == 0 ? i.toInt().toString() : i.toStringAsFixed(1));
      }
    } else {
      // For feet, create proper feet'inches format
      for (int feet = 3; feet <= 8; feet++) {
        for (int inches = 0; inches < 12; inches++) {
          if (feet == 8 && inches > 6) break; // Stop at 8'6"
          
          // Convert feet and inches to total feet as decimal
          double totalFeet = feet + (inches / 12.0);
          actualValues.add(totalFeet);
          heightValues.add("$feet'$inches");
        }
      }
    }
    
    // Find the closest index to current value
    int selectedIndex = 0;
    double minDiff = double.infinity;
    for (int i = 0; i < actualValues.length; i++) {
      double diff = (actualValues[i] - value).abs();
      if (diff < minDiff) {
        minDiff = diff;
        selectedIndex = i;
      }
    }

    return Container(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection indicator
          Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
          ),
          
          // Horizontal scrollable numbers
          SizedBox(
            height: 80,
            child: RotatedBox(
              quarterTurns: 3,
              child: ListWheelScrollView.useDelegate(
                controller: FixedExtentScrollController(
                  initialItem: selectedIndex,
                ),
                itemExtent: 50,
                perspective: 0.005,
                onSelectedItemChanged: (index) {
                  if (index >= 0 && index < actualValues.length) {
                    onChanged(actualValues[index]);
                  }
                },
                physics: const FixedExtentScrollPhysics(),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: actualValues.length,
                  builder: (context, index) {
                    final currentValue = actualValues[index];
                    final isSelected = (currentValue - value).abs() < 0.05; // Small tolerance
                    
                    return RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          heightValues[index],
                          style: GoogleFonts.lato(
                            fontSize: isSelected ? 18 : 14, // Slightly smaller for feet format
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? primaryColor : Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalWeightSelector({
    required int value,
    required int minValue,
    required int maxValue,
    required Function(int) onChanged,
  }) {
    return Container(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection indicator
          Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
          ),
          
          // Horizontal scrollable numbers
          SizedBox(
            height: 80,
            child: RotatedBox(
              quarterTurns: 3,
              child: ListWheelScrollView.useDelegate(
                controller: FixedExtentScrollController(
                  initialItem: value - minValue,
                ),
                itemExtent: 50,
                perspective: 0.005,
                onSelectedItemChanged: (index) {
                  onChanged(minValue + index);
                },
                physics: const FixedExtentScrollPhysics(),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: maxValue - minValue + 1,
                  builder: (context, index) {
                    final currentValue = minValue + index;
                    final isSelected = currentValue == value;
                    
                    return RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          currentValue.toString(),
                          style: GoogleFonts.lato(
                            fontSize: isSelected ? 20 : 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? primaryColor : Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMICard() {
    double bmi = _calculateBMI();
    String bmiCategory = _getBMICategory(bmi);
    Color bmiColor = _getBMIColor(bmi);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bmiColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics,
                  color: bmiColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI Calculator',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Body Mass Index',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    bmi.toStringAsFixed(1),
                    style: GoogleFonts.lato(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: bmiColor,
                    ),
                  ),
                  Text(
                    'BMI',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 35,
                color: Colors.grey[300],
              ),
              Column(
                children: [
                  Text(
                    bmiCategory,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: bmiColor,
                    ),
                  ),
                  Text(
                    'Category',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateBMI() {
    // Convert height to meters
    double heightInM;
    if (_heightUnit == 'cm') {
      heightInM = _selectedHeight / 100;
    } else {
      // Convert feet to meters (1 foot = 0.3048 meters)
      heightInM = _selectedHeight * 0.3048;
    }

    // Convert weight to kg
    double weightInKg;
    if (_weightUnit == 'kg') {
      weightInKg = _selectedWeight.toDouble();
    } else {
      weightInKg = _selectedWeight / 2.205; // lbs to kg
    }

    return weightInKg / (heightInM * heightInM);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  void _saveAndContinue() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Convert height to cm if it's in feet for consistent storage
    double heightInCm = _selectedHeight;
    if (_heightUnit == 'ft') {
      // Convert feet to centimeters (1 ft = 30.48 cm)
      heightInCm = _selectedHeight * 30.48;
    }

    // Convert weight to kg if it's in lbs for consistent storage
    int weightInKg = _selectedWeight;
    if (_weightUnit == 'lbs') {
      // Convert pounds to kilograms (1 lb = 0.453592 kg)
      weightInKg = (_selectedWeight * 0.453592).round();
    }
    
    // Save basic info (age and gender)
    userProvider.updateBasicInfo(
      age: _selectedAge,
      gender: _selectedGender,
    );

    // Save physical measurements (always in metric units)
    userProvider.updatePhysicalInfo(
      height: heightInCm,
      weight: weightInKg,
    );

    // Save user's preferred units for display purposes
    userProvider.updateProfileField('height_unit', _heightUnit);
    userProvider.updateProfileField('weight_unit', _weightUnit);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile saved successfully!'),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to next step (you can customize this)
    Navigator.pushReplacementNamed(context, '/lifestyle-goal');
  }

  Widget _buildAgeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cake,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Age',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Age Selector
          Container(
            height: 40,
            child: _buildHorizontalAgeSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gender',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Gender Selector - Toggle Buttons
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: _genderOptions.map((gender) {
                final isSelected = _selectedGender == gender;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGender = gender;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        gender,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalAgeSelector() {
    return Container(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection indicator
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
          ),
          
          // Horizontal scrollable numbers
          SizedBox(
            height: 80,
            child: RotatedBox(
              quarterTurns: 3,
              child: ListWheelScrollView.useDelegate(
                controller: FixedExtentScrollController(
                  initialItem: _selectedAge - 13,
                ),
                itemExtent: 40,
                perspective: 0.002,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedAge = index + 13;
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: 88,
                  builder: (context, index) {
                    final age = index + 13;
                    final isSelected = age == _selectedAge;
                    return RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          '$age',
                          style: GoogleFonts.lato(
                            fontSize: isSelected ? 18 : 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? primaryColor : Colors.black54,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}