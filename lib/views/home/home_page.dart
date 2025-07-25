// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nutrinotion_app/backend/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrinotion_app/backend/providers/auth_provider.dart';
import 'package:nutrinotion_app/backend/providers/user_provider.dart';
import '../profile/edit_profile_page_new.dart';
import 'package:nutrinotion_app/backend/services/mess_service.dart';
import 'package:nutrinotion_app/const/custom_colors.dart';
import 'package:nutrinotion_app/const/page_transitions.dart';
import 'package:nutrinotion_app/views/auth/login_page.dart';

import '../../backend/providers/ai_provider.dart';
import '../../backend/providers/firestore_provider.dart';
import '../../backend/providers/personalized_food_provider.dart';
import '../../backend/services/calorie_tracking_service.dart';
import '../profile/profile_page_new.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MessService _messService = MessService();

  // Current day of the week
  final currentDay = DateFormat('EEEE').format(DateTime.now());

  // Check if it's past meal time
  bool _isMealTimePassed(String mealType) {
    final now = DateTime.now().hour;
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return now >= 11; // After 11 AM
      case 'lunch':
        return now >= 15; // After 3 PM
      case 'snacks':
        return now >= 17; // After 5 PM
      case 'dinner':
        return now >= 22; // After 10 PM
      default:
        return false;
    }
  }

  // Determine which meal type based on current time
  String _determineMealType(DateTime time) {
    final hour = time.hour;
    
    if (hour >= 6 && hour < 11) {
      return 'Breakfast';
    } else if (hour >= 11 && hour < 15) {
      return 'Lunch';
    } else if (hour >= 15 && hour < 19) {
      return 'Snacks';
    } else {
      return 'Dinner';
    }
  }

  // Check if it's a future meal (before its designated time)
  bool _isFutureMeal(String mealType) {
    final now = DateTime.now().hour;
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return now < 6; // Before 6 AM
      case 'lunch':
        return now < 12; // Before 12 PM
      case 'snacks':
        return now < 16; // Before 4 PM
      case 'dinner':
        return now < 18; // Before 6 PM
      default:
        return false;
    }
  }

  // Get appropriate icon for food items
  IconData _getFoodIcon(String foodName) {
    final name = foodName.toLowerCase();
    if (name.contains('rice') ||
        name.contains('biryani') ||
        name.contains('dal')) {
      return Icons.rice_bowl;
    } else if (name.contains('roti') ||
        name.contains('paratha') ||
        name.contains('bread')) {
      return Icons.bakery_dining;
    } else if (name.contains('curry') ||
        name.contains('sabzi') ||
        name.contains('sambar')) {
      return Icons.soup_kitchen;
    } else if (name.contains('chai') ||
        name.contains('tea') ||
        name.contains('coffee')) {
      return Icons.local_cafe;
    } else if (name.contains('samosa') ||
        name.contains('pakora') ||
        name.contains('puri')) {
      return Icons.fastfood;
    } else if (name.contains('idli') ||
        name.contains('upma') ||
        name.contains('poha')) {
      return Icons.breakfast_dining;
    } else if (name.contains('paneer') ||
        name.contains('chicken') ||
        name.contains('egg') ||
        name.contains('fish')) {
      return Icons.dinner_dining;
    } else {
      return Icons.restaurant;
    }
  }

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final aiProvider = Provider.of<AiProvider>(context, listen: false);
      final firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
      final personalizedFoodProvider = Provider.of<PersonalizedFoodProvider>(context, listen: false);
      
      // Get personalized food data
      await personalizedFoodProvider.getPersonalizedFood(authProvider.userId ?? '');
      
      final res = await aiProvider.getUserDetails(authProvider.userId ?? '');
      final menu = await aiProvider.getMenuDetails();

      if (res != null && menu.isNotEmpty && authProvider.userId != null) {
        final check = await firestoreProvider.checkForPersonalizedFood(authProvider.userId ?? '');
        if (check == false) {
          return;
        }
        final aiData = aiProvider.formatDataForAI(res, menu);
        final recommendations =
            await aiProvider.generateRecommendations(aiData);
        await firestoreProvider.updatePersonalizedMenu(
            authProvider.userId ?? '', recommendations);
      } else {
        print("Failed to fetch user details or menu.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final personalizedFoodProvider = Provider.of<PersonalizedFoodProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 255, 251, 247),
      drawer: _buildSidebar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            SizedBox(height: 16),

            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Progress (moved to top)
                  _buildTotalCaloriesSummary(),

                  const SizedBox(height: 20),

                  // View Full Menu Button (moved to top)
                  _buildViewFullMenuButton(),

                  const SizedBox(height: 24),

                  // Meal Plan Title
                  Text(
                    'Today\'s Personalized Meal Plan',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  personalizedFoodProvider.isLoading
                  ? Center(child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 2.5,
                  ))
                  : personalizedFoodProvider.errorMessage != null
                      ? Center(child: Text(personalizedFoodProvider.errorMessage!))
                  : personalizedFoodProvider.personalizedMenu != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (personalizedFoodProvider.personalizedMenu![currentDay]?['Breakfast'] != null)
                              _buildMealSection(
                                  'Breakfast',
                                  List<Map<String, dynamic>>.from(
                                      personalizedFoodProvider.personalizedMenu![currentDay]['Breakfast'])),
                            const SizedBox(height: 20),
                            if (personalizedFoodProvider.personalizedMenu![currentDay]?['Lunch'] != null)
                              _buildMealSection(
                                  'Lunch',
                                  List<Map<String, dynamic>>.from(
                                      personalizedFoodProvider.personalizedMenu![currentDay]['Lunch'])),
                            const SizedBox(height: 20),
                            if (personalizedFoodProvider.personalizedMenu![currentDay]?['Snacks'] != null)
                              _buildMealSection(
                                  'Snacks',
                                  List<Map<String, dynamic>>.from(
                                      personalizedFoodProvider.personalizedMenu![currentDay]['Snacks'])),
                            const SizedBox(height: 20),
                            if (personalizedFoodProvider.personalizedMenu![currentDay]?['Dinner'] != null)
                              _buildMealSection(
                                  'Dinner',
                                  List<Map<String, dynamic>>.from(
                                      personalizedFoodProvider.personalizedMenu![currentDay]['Dinner'])),
                          ],
                        )
                      : Center(child: Text('No personalized menu available.')),

                  const SizedBox(height: 24),

                  // Health Tip
                  _buildHealthTip(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Consumer2<AuthProvider, UserProvider>(
              builder: (context, authProvider, userProvider, child) {
                return DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          authProvider.userDisplayName?.substring(0, 1) ?? 'U',
                          style: GoogleFonts.lato(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        authProvider.userDisplayName ?? 'User',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        authProvider.userEmail ?? '',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.home,
              title: 'Home',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.edit,
              title: 'Edit Profile', 
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.restaurant_menu,
              title: 'Nutrition Tracker',
              onTap: () {
                Navigator.pop(context);
                // Navigate to nutrition tracker
              },
            ),
            _buildDrawerItem(
              icon: Icons.analytics,
              title: 'Analytics',
              onTap: () {
                Navigator.pop(context);
                // Navigate to analytics
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            const Divider(color: Colors.white30),
            _buildDrawerItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                // Navigate to help
              },
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }



  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 0, 0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top header with menu and app title
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 16,
            children: [
              IconButton(
                icon: const Icon(Icons.menu,
                    color: Color.fromARGB(255, 31, 31, 31)),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Text(
                'NutriNotion',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color.fromARGB(255, 31, 31, 31),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(String mealType, List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.no_meals,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'No items available for $mealType',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    int totalCalories =
        items.fold(0, (sum, item) => sum + (int.tryParse(item['calories'].toString()) ?? 0));
    bool isTimePassed = _isMealTimePassed(mealType);
    bool isFutureMeal = _isFutureMeal(mealType);

    // Check if all items in this meal are completed
    bool allItemsCompleted = items.every((item) => item['isChecked'] == true);

    // Get count of completed items
    int completedCount = items
        .where((item) => item['isChecked'] == true)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal type header with + icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  mealType.toUpperCase(),
                  style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: allItemsCompleted
                          ? Colors.grey
                          : const Color.fromARGB(255, 27, 27, 27),
                      letterSpacing: 1.2),
                ),
                if (completedCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: allItemsCompleted ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$completedCount/${items.length}',
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showFullMenuDialog(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (allItemsCompleted)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  )
                else if (isFutureMeal)
                  Icon(
                    Icons.schedule,
                    color: Colors.blue[400],
                    size: 20,
                  )
                else if (isTimePassed)
                  Icon(
                    Icons.access_time_filled,
                    color: Colors.grey,
                    size: 20,
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Meal items
        ...items.asMap().entries.map((entry) {
          final item = entry.value;
          final itemKey = '${mealType.toLowerCase()}_${item['item']}';
          final isItemCompleted = item['isChecked'] ?? false; // Get checked status from item data
          final shouldBeGrayedOut = isItemCompleted || isTimePassed;
          final canToggle = !isFutureMeal; // Disable toggle for future meals

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: shouldBeGrayedOut ? Colors.grey[100] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: shouldBeGrayedOut
                      ? Colors.grey.shade300
                      : Colors.grey.shade200),
              boxShadow: shouldBeGrayedOut
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: shouldBeGrayedOut
                        ? Colors.grey.withOpacity(0.3)
                        : primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isFutureMeal ? Icons.schedule : Icons.restaurant,
                    color: shouldBeGrayedOut ? Colors.grey : primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['item'],
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: shouldBeGrayedOut
                              ? Colors.grey[600]
                              : Colors.black87,
                          decoration: isItemCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${item['quantity']} • ${item['calories']} kcal',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: shouldBeGrayedOut
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                              decoration: isItemCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (isFutureMeal) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 10,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Soon',
                                    style: GoogleFonts.lato(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (canToggle)
                  Tooltip(
                    message: isItemCompleted
                        ? 'Mark as incomplete'
                        : 'Mark as completed',
                    child: GestureDetector(
                      onTap: () => _toggleItemCompletion(
                          itemKey, 
                          item['item'], 
                          mealType,
                          int.parse(item['calories'].toString())),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isTimePassed
                              ? (isItemCompleted
                                  ? Colors.grey.withAlpha(40)
                                  : Colors.grey.withAlpha(20))
                              : (isItemCompleted
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isTimePassed
                                ? (isItemCompleted
                                    ? Colors.grey.withOpacity(0.4)
                                    : Colors.grey.withOpacity(0.3))
                                : (isItemCompleted
                                    ? Colors.orange.withOpacity(0.3)
                                    : Colors.green.withOpacity(0.3)),
                            width: 1,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isItemCompleted ? Icons.close : Icons.check,
                            key: ValueKey(isItemCompleted),
                            color: isTimePassed
                                ? (isItemCompleted
                                    ? Colors.grey[600]
                                    : Colors.grey[500])
                                : (isItemCompleted
                                    ? Colors.orange
                                    : Colors.green),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (isFutureMeal)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: Colors.blue[400],
                      size: 20,
                    ),
                  ),
              ],
            ),
          );
        }),

        // Total calories for this meal
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: allItemsCompleted || isTimePassed
                ? LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.2),
                      Colors.grey.withOpacity(0.1)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: allItemsCompleted || isTimePassed
                    ? Colors.grey.withOpacity(0.5)
                    : primaryColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$mealType Total:',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: allItemsCompleted || isTimePassed
                      ? Colors.grey[600]
                      : primaryColor,
                  decoration:
                      allItemsCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              Text(
                '$totalCalories kcal',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: allItemsCompleted || isTimePassed
                      ? Colors.grey[600]
                      : primaryColor,
                  decoration:
                      allItemsCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCaloriesSummary() {
    final personalizedFoodProvider = Provider.of<PersonalizedFoodProvider>(context);
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    double progress = 0;
    int totalCalories = 0;
    int remainingCalories = 0;
    const targetCalories = 1400;
    Future.microtask(() async {
      totalCalories = await personalizedFoodProvider.getTotalCaloriesForDate(authProvider.userId ?? '', today);
      progress = totalCalories / targetCalories;
      remainingCalories = targetCalories - totalCalories;
    });
    
    // Calculate status color
    Color statusColor;
    String statusText;
    if (progress >= 1.2) {
      statusColor = Colors.red;
      statusText = 'Exceeded Target';
    } else if (progress >= 1.0) {
      statusColor = Colors.orange;
      statusText = 'Target Reached';
    } else if (progress >= 0.8) {
      statusColor = Colors.green;
      statusText = 'Almost There';
    } else {
      statusColor = Colors.white;
      statusText = 'In Progress';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Progress',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Today\'s Calorie Intake',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalCalories',
                    style: GoogleFonts.lato(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'of $targetCalories kcal',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    remainingCalories > 0 ? '$remainingCalories' : '0',
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'kcal remaining',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress > 1.0 ? 1.0 : progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor,
                      statusColor.withOpacity(0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(progress * 100).toInt()}% of daily target',
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewFullMenuButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor, width: 2),
      ),
      child: ElevatedButton(
        onPressed: () {
          _showFullMenuDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              color: primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'View Today\'s Full Mess Menu',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleItemCompletion(String itemKey, String itemName, String mealType, int calories) async {
    // Start with updating UI to show loading
    final personalizedFoodProvider = Provider.of<PersonalizedFoodProvider>(context, listen: false);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userId == null) {
        print('User ID is null');
        return;
      }

      final calorieTrackingService = CalorieTrackingService();
      
      // Use consistent date format
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final currentDay = DateFormat('EEEE').format(DateTime.now());

      // Find and update the item in personalizedMenu
      if (personalizedFoodProvider.personalizedMenu != null && 
          personalizedFoodProvider.personalizedMenu![currentDay] != null) {
        final mealItems = List<Map<String, dynamic>>.from(
            personalizedFoodProvider.personalizedMenu![currentDay][mealType]);
        
        for (var i = 0; i < mealItems.length; i++) {
          if (mealItems[i]['item'] == itemName) {
            final bool currentCheckedState = mealItems[i]['isChecked'] ?? false;
            mealItems[i]['isChecked'] = !currentCheckedState;
            
            // Update menu first, then calories
            await personalizedFoodProvider.updatePersonalizedFood(
              userId: authProvider.userId ?? '',
              day: currentDay,
              mealType: mealType,
              updatedItems: mealItems
            );
            
            // Update calories tracking
            await calorieTrackingService.updateCalorieIntake(
              userId: authProvider.userId ?? '',
              date: today,
              calories: calories,
              isIncrement: !currentCheckedState,
              itemKey: itemKey,
              itemName: itemName,
              mealType: mealType
            );
            
            // Notify the provider to refresh
            personalizedFoodProvider.notifyListeners();
            break;
          }
        }
      }
    } on Exception catch (e) {
      // If any error occurs, revert the UI change
      print('Error toggling item completion: $e');
    }

    // Show success message
    final currentItem = personalizedFoodProvider.personalizedMenu![currentDay][mealType]
        .firstWhere((item) => item['item'] == itemName);
    final isNowCompleted = currentItem['isChecked'] ?? false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isNowCompleted ? Icons.check_circle : Icons.remove_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isNowCompleted
                    ? '$itemName from $mealType marked as completed!'
                    : '$itemName from $mealType marked as incomplete!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isNowCompleted ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHealthTip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF8F9FA),
            const Color(0xFFF1F3F4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tips_and_updates,
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
                  'Health Tip of the Day',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Drink at least 2 liters of water daily to support your fitness goals and maintain good health.',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullMenuDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Full Mess Menu',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              // Tab bar and content
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey[600],
                          indicator: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          indicatorPadding: const EdgeInsets.all(2),
                          labelStyle: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(
                              height: 44,
                              text: 'Breakfast',
                            ),
                            Tab(
                              height: 44,
                              text: 'Lunch',
                            ),
                            Tab(
                              height: 44,
                              text: 'Snacks',
                            ),
                            Tab(
                              height: 44,
                              text: 'Dinner',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildMenuList('Breakfast', scrollController),
                            _buildMenuList('Lunch', scrollController),
                            _buildMenuList('Snacks', scrollController),
                            _buildMenuList('Dinner', scrollController),
                          ],
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
    );
  }

  String _getCurrentDayName() {
    return DateFormat('EEEE').format(DateTime.now()).toLowerCase();
  }

  Widget _buildMenuList(String mealType, [ScrollController? scrollController]) {
    final currentDay = _getCurrentDayName();
    return StreamBuilder<DocumentSnapshot>(
      stream: _messService.getMenuStream(currentDay).cast<DocumentSnapshot>(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load menu for ${currentDay[0].toUpperCase()}${currentDay.substring(1)}',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Instead of setState, we'll just call the stream again
                    _messService.getMenuStream("wednesday");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.lato(),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final menuData = snapshot.data!.data() as Map<String, dynamic>;
        final itemsRaw = menuData[mealType.toLowerCase()] ?? [];

        if (itemsRaw.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No items available for $mealType',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Handle menu items
        List<Map<String, dynamic>> menuItems = [];
        if (itemsRaw is List) {
          menuItems = itemsRaw.map<Map<String, dynamic>>((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else if (item is String) {
              return {
                'item': item,
                'description': 'Delicious $item prepared fresh',
                'calories': 200, // Default calories
                'isVegetarian': !item.toLowerCase().contains('chicken') && 
                               !item.toLowerCase().contains('fish') && 
                               !item.toLowerCase().contains('egg') &&
                               !item.toLowerCase().contains('mutton'),
                'category': 'Indian',
              };
            } else {
              return {
                'item': 'Unknown Item',
                'description': 'Description not available',
                'calories': 0,
                'isVegetarian': true,
                'category': 'Unknown'
              };
            }
          }).toList();
        }
        
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Food icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withOpacity(0.1),
                            primaryColor.withOpacity(0.05)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getFoodIcon(item['item'] as String? ?? ''),
                        color: primaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Food details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'] as String? ?? 'Unknown Item',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['description'] as String? ??
                                'No description available',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Calories and category badges
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${item['calories'] ?? 0} kcal',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Add button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add,
                            color: Colors.white, size: 20),
                        onPressed: () {
                          // Ensure all required fields are present
                          final itemToAdd = {
                            'item': item['item'] as String? ?? 'Unknown Item',
                            'calories': item['calories'] as int? ?? 0,
                            'description': item['description'] as String? ?? 'No description available',
                            'isVegetarian': item['isVegetarian'] as bool? ?? true,
                            'category': item['category'] as String? ?? 'Indian',
                          };
                          Navigator.pop(context);
                          _addToNutritionTracker(itemToAdd);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addToNutritionTracker(Map<String, dynamic> item) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final personalizedFoodProvider = Provider.of<PersonalizedFoodProvider>(context, listen: false);
    
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final mealType = _determineMealType(DateTime.now());

      await personalizedFoodProvider.addToPersonalizedMenu(
        userId: authProvider.userId!,
        day: today,
        mealType: mealType,
        newItem: {
          'item': item['item'],
          'calories': item['calories'],
          'quantity': '1 serving',
          'description': item['description'],
          'isVegetarian': item['isVegetarian'],
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item['item']} added to your personalized menu!'),
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.lato(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              authProvider.signOut().then((success) {
                if (success) {
                  context.pushReplacementFade(const LoginPage(), duration: 600);
                }
              });
            },
            child: Text(
              'Logout',
              style: GoogleFonts.lato(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
