import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../backend/providers/user_provider.dart';
import '../../const/custom_colors.dart';
import '../../backend/providers/nutrition_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late TextEditingController _allergyController;
  String _selectedGender = '';
  String _selectedActivityLevel = '';
  String _selectedDietaryPreference = '';
  String _selectedGoal = '';
  List<String> _selectedAllergies = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Initialize controllers with existing user data
    _nameController = TextEditingController(text: userProvider.user.name ?? '');
    _heightController =
        TextEditingController(text: userProvider.user.height?.toString() ?? '');
    _weightController =
        TextEditingController(text: userProvider.user.weight?.toString() ?? '');
    _ageController =
        TextEditingController(text: userProvider.user.age?.toString() ?? '');
    _allergyController = TextEditingController();

    // Initialize dropdown values with default selections if empty
    _selectedGender = (userProvider.user.gender?.isNotEmpty == true &&
            ['Male', 'Female', 'Other'].contains(userProvider.user.gender))
        ? userProvider.user.gender!
        : 'Male';

    _selectedActivityLevel =
        (userProvider.user.activityLevel?.isNotEmpty == true &&
                ['Sedentary', 'Moderate', 'Active']
                    .contains(userProvider.user.activityLevel))
            ? userProvider.user.activityLevel!
            : 'Moderate';

    _selectedDietaryPreference =
        (userProvider.user.dietType?.isNotEmpty == true &&
                ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'No Preference']
                    .contains(userProvider.user.dietType))
            ? userProvider.user.dietType!
            : 'No Preference';

    _selectedGoal = (userProvider.user.fitnessGoal?.isNotEmpty == true &&
            ['Gain Weight', 'Lose Weight', 'Maintain Fitness']
                .contains(userProvider.user.fitnessGoal))
        ? userProvider.user.fitnessGoal!
        : 'Maintain Fitness';

    // Initialize allergies list
    _selectedAllergies = List<String>.from(userProvider.user.allergies ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final nutritionProvider =
          Provider.of<NutritionProvider>(context, listen: false);

      userProvider.updateBasicInfo(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        gender: _selectedGender,
      );

      // Update height and weight
      userProvider.updatePhysicalInfo(
        height: double.parse(_heightController.text),
        weight: int.parse(_weightController.text),
      );

      userProvider.updateDietInfo(
        dietType: _selectedDietaryPreference,
        allergies: _selectedAllergies,
      );

      userProvider.updateLifestyleInfo(
        activityLevel: _selectedActivityLevel,
        fitnessGoal: _selectedGoal,
      );

      // Recalculate and save nutrition/calorie data
      await nutritionProvider
          .recalculateAndSaveUserNutrition(userProvider.user);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: const Color.fromARGB(255, 245, 56, 42),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 251, 247),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Update Your Profile',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Keep your information up to date for better recommendations',
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form Section
            Container(
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Personal Information'),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _ageController,
                        label: 'Age',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 0 || age > 120) {
                            return 'Please enter a valid age';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Physical Details'),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _heightController,
                        label: 'Height (cm)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your height';
                          }
                          final height = double.tryParse(value);
                          if (height == null || height < 0 || height > 300) {
                            return 'Please enter a valid height';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _weightController,
                        label: 'Weight (kg)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          final weight = double.tryParse(value);
                          if (weight == null || weight < 0 || weight > 500) {
                            return 'Please enter a valid weight';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Preferences'),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        value: _selectedGender,
                        label: 'Gender',
                        items: const ['Male', 'Female', 'Other'],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedGender = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        value: _selectedActivityLevel,
                        label: 'Activity Level',
                        items: const ['Sedentary', 'Moderate', 'Active'],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedActivityLevel = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        value: _selectedDietaryPreference,
                        label: 'Dietary Preference',
                        items: const [
                          'Vegetarian',
                          'Non-Vegetarian',
                          'Vegan',
                          'No Preference'
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedDietaryPreference = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        value: _selectedGoal,
                        label: 'Fitness Goal',
                        items: const [
                          'Gain Weight',
                          'Lose Weight',
                          'Maintain Fitness'
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedGoal = value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Allergies'),
                      const SizedBox(height: 16),
                      _buildAllergiesSection(),
                      const SizedBox(height: 32),
                      // Save Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryColor, width: 2),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.save_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Save Changes',
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.lato(
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    // Ensure we have a valid, unique list of items
    final uniqueItems = items.toSet().toList();
    // Ensure we always have a valid value
    final effectiveValue = value.isNotEmpty ? value : uniqueItems.first;

    return DropdownButtonFormField<String>(
      value: effectiveValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: primaryColor,
            size: 24,
          ),
        ),
      ),
      style: GoogleFonts.lato(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      icon: const SizedBox.shrink(), // Hide default icon
      dropdownColor: Colors.white,
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      isDense: false,
      items: uniqueItems.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              item,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a $label';
        }
        return null;
      },
      menuMaxHeight: 200,
    );
  }

  Widget _buildAllergiesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Allergy',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _allergyController,
                  decoration: InputDecoration(
                    hintText: 'Enter an allergy...',
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
            Text(
              'Current Allergies:',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
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

  void _addAllergy(String allergy) {
    if (allergy.trim().isNotEmpty &&
        !_selectedAllergies.contains(allergy.trim())) {
      setState(() {
        _selectedAllergies.add(allergy.trim());
        _allergyController.clear();
      });
    }
  }
}
