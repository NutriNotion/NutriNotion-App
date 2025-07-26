// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrinotion_app/backend/providers/auth_provider.dart';
import 'package:nutrinotion_app/backend/providers/user_provider.dart';
import 'package:nutrinotion_app/backend/services/mess_service.dart';
import 'package:nutrinotion_app/const/custom_colors.dart';
import 'package:nutrinotion_app/const/page_transitions.dart';
import 'package:nutrinotion_app/views/auth/login_page.dart';
import '../../backend/providers/ai_provider.dart';
import '../../backend/providers/firestore_provider.dart';
import '../../backend/providers/personalized_food_provider.dart';
import '../../backend/services/calorie_tracking_service.dart';
import '../profile/profile_page_new.dart';
import '../analytics/analytics_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MessService _messService = MessService();

  // Loading states for individual items
  final Map<String, bool> _itemLoadingStates = {};

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
          return;
        }
        final aiData = aiProvider.formatDataForAI(res, menu);
        print("AI Data: $aiData");
        final recommendations =
            await aiProvider.generateRecommendations(aiData);
        print("Recommendations: $recommendations");
        await firestoreProvider.updatePersonalizedMenu(
            authProvider.userId ?? '', recommendations);
      } else {
        print("Failed to fetch user details or menu.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final personalizedFoodProvider =
        Provider.of<PersonalizedFoodProvider>(context);
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

                  // Health Tip
                  _buildHealthTip(),

                  SizedBox(height: 20),

                  // Quick Analytics Access
                  _buildQuickAnalyticsCard(),

                  SizedBox(height: 20),

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
                      ? Center(
                          child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 2.5,
                        ))
                      : personalizedFoodProvider.errorMessage != null
                          ? Center(
                              child:
                                  Text(personalizedFoodProvider.errorMessage!))
                          : personalizedFoodProvider.personalizedMenu != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (personalizedFoodProvider
                                                .personalizedMenu![currentDay]
                                            ?['Breakfast'] !=
                                        null)
                                      _buildMealSection(
                                          'Breakfast',
                                          List<Map<String, dynamic>>.from(
                                              personalizedFoodProvider
                                                      .personalizedMenu![
                                                  currentDay]['Breakfast'])),
                                    const SizedBox(height: 20),
                                    if (personalizedFoodProvider
                                                .personalizedMenu![currentDay]
                                            ?['Lunch'] !=
                                        null)
                                      _buildMealSection(
                                          'Lunch',
                                          List<Map<String, dynamic>>.from(
                                              personalizedFoodProvider
                                                      .personalizedMenu![
                                                  currentDay]['Lunch'])),
                                    const SizedBox(height: 20),
                                    if (personalizedFoodProvider
                                                .personalizedMenu![currentDay]
                                            ?['Snacks'] !=
                                        null)
                                      _buildMealSection(
                                          'Snacks',
                                          List<Map<String, dynamic>>.from(
                                              personalizedFoodProvider
                                                      .personalizedMenu![
                                                  currentDay]['Snacks'])),
                                    const SizedBox(height: 20),
                                    if (personalizedFoodProvider
                                                .personalizedMenu![currentDay]
                                            ?['Dinner'] !=
                                        null)
                                      _buildMealSection(
                                          'Dinner',
                                          List<Map<String, dynamic>>.from(
                                              personalizedFoodProvider
                                                      .personalizedMenu![
                                                  currentDay]['Dinner'])),
                                  ],
                                )
                              : _buildPersonalizedMenuCookingMessage(),
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
              icon: Icons.analytics,
              title: 'Analytics',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsPage(),
                  ),
                );
              },
            ),
            const Divider(color: Colors.white30),
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
            spacing: 6,
            children: [
              IconButton(
                icon: const Icon(Icons.menu,
                    color: Color.fromARGB(255, 31, 31, 31)),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Text(
                'NutriNotion',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color.fromARGB(255, 54, 54, 54),
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

    int totalCalories = items.fold(0,
        (sum, item) => sum + (int.tryParse(item['calories'].toString()) ?? 0));
    bool isTimePassed = _isMealTimePassed(mealType);
    bool isFutureMeal = _isFutureMeal(mealType);

    // Check if all items in this meal are completed
    bool allItemsCompleted = items.every((item) => item['isChecked'] == true);

    // Get count of completed items
    int completedCount =
        items.where((item) => item['isChecked'] == true).length;

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
          final isItemCompleted =
              item['isChecked'] ?? false; // Get checked status from item data
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
                        item['item'] ?? 'null',
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
                      onTap: _itemLoadingStates[itemKey] == true
                          ? null
                          : () => _toggleItemCompletion(itemKey, item['item'],
                              mealType, int.parse(item['calories'].toString())),
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
                          child: _itemLoadingStates[itemKey] == true
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    key: ValueKey('loading_$itemKey'),
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isTimePassed
                                          ? Colors.grey[500]!
                                          : primaryColor,
                                    ),
                                  ),
                                )
                              : Icon(
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
    final personalizedFoodProvider =
        Provider.of<PersonalizedFoodProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final totalCalories = personalizedFoodProvider.totalCalories;
    final targetCalories = userProvider.user.calorieTargetPerDay ??
        1400; // Default to 1400 if not set
    final progress = totalCalories / targetCalories;
    final remainingCalories = targetCalories - totalCalories;

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
            color: primaryColor.withOpacity(0.2),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          Stack(
            children: [
              // Background progress bar
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
              ),
              // Foreground progress bar
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress > 1.0 ? 1.0 : progress,
                child: Container(
                  height: 10,
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
                        color: statusColor.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  void _toggleItemCompletion(
      String itemKey, String itemName, String mealType, int calories) async {
    final personalizedFoodProvider =
        Provider.of<PersonalizedFoodProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.userId == null) {
      print('User ID is null');
      return;
    }

    // Set loading state for this specific item
    setState(() {
      _itemLoadingStates[itemKey] = true;
    });

    try {
      final calorieTrackingService = CalorieTrackingService();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final currentDay = DateFormat('EEEE').format(DateTime.now());

      print('Toggling item: $itemName in $mealType for day: $currentDay (date: $today)');

      if (personalizedFoodProvider.personalizedMenu != null &&
          personalizedFoodProvider.personalizedMenu![currentDay] != null) {
        final mealItems = List<Map<String, dynamic>>.from(
            personalizedFoodProvider.personalizedMenu![currentDay][mealType]);

        // Find the item and toggle its checked state
        final targetItemIndex =
            mealItems.indexWhere((item) => item['item'] == itemName);
        if (targetItemIndex != -1) {
          final bool currentCheckedState =
              mealItems[targetItemIndex]['isChecked'] ?? false;
          final bool newCheckedState = !currentCheckedState;

          print('Current state: $currentCheckedState, New state: $newCheckedState');

          // Update the item state locally first for immediate UI feedback
          mealItems[targetItemIndex]['isChecked'] = newCheckedState;

          // Update both services in parallel
          await Future.wait([
            personalizedFoodProvider.updatePersonalizedFood(
                userId: authProvider.userId!,
                day: currentDay,
                mealType: mealType,
                updatedItems: mealItems),
            calorieTrackingService.updateCalorieIntake(
                userId: authProvider.userId!,
                date: today,
                calories: calories,
                isIncrement: newCheckedState,
                itemKey: itemKey,
                itemName: itemName,
                mealType: mealType),
          ]);

          // Refresh calorie count after successful update
          await personalizedFoodProvider.getTotalCaloriesForDate(
              authProvider.userId!, today);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    newCheckedState ? Icons.check_circle : Icons.remove_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      newCheckedState
                          ? '$itemName from $mealType marked as completed!'
                          : '$itemName from $mealType marked as incomplete!',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: newCheckedState ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error toggling item completion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update item: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      // Clear loading state for this item
      setState(() {
        _itemLoadingStates[itemKey] = false;
      });
    }
  }

  Widget _buildHealthTip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb_outline,
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
                  'Health Tip',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stay hydrated! Drink 8-10 glasses of water daily to boost metabolism and aid digestion.',
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
    );
  }

  Widget _buildQuickAnalyticsCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AnalyticsPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.analytics_outlined,
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
                    'View Analytics',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your daily progress and streaks',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedMenuCookingMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.05),
            primaryColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Animated cooking icon
          Container(
            height: 80,
            width: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle
            ),
            child: Text(
              '',
              style: TextStyle(fontSize: 50),
            ),
          ),

          const SizedBox(height: 24),

          // Main message
          Text(
            '🍳 Your Personalized Meal is Being Cooked!',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Our nutrition experts are preparing a customized meal plan just for you based on your preferences and goals.',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(3, (index) {
                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 600 + (index * 200)),
                  tween: Tween<double>(begin: 0.3, end: 1.0),
                  builder: (context, double value, child) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(value),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                );
              }),
            ],
          ),

          const SizedBox(height: 20),

          // Action hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'This usually takes a few moments',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
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
                    _messService.getMenuStream(currentDay);
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
                        _getFoodIcon(item['name'] as String? ?? ''),
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
                          final itemToAdd = {
                            'item': item['name'] as String? ?? 'Unknown Item',
                            'calories': item['calories'] as int? ?? 0,
                            'description': item['description'] as String? ??
                                'No description available',
                          };
                          Navigator.pop(context);
                          print(itemToAdd);
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
    final personalizedFoodProvider =
        Provider.of<PersonalizedFoodProvider>(context, listen: false);

    // Show dialog to let user choose meal type
    final String? selectedMealType = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add to Meal Plan',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select which meal you want to add "${item['item']}" to:',
                style: GoogleFonts.lato(),
              ),
              const SizedBox(height: 16),
              ...['Breakfast', 'Lunch', 'Snacks', 'Dinner'].map((mealType) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(mealType),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        mealType,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );

    if (selectedMealType == null) return; // User cancelled

    try {
      final currentDay = DateFormat('EEEE').format(DateTime.now()); // Use day name like 'Friday'

      await personalizedFoodProvider.addToPersonalizedMenu(
        userId: authProvider.userId!,
        day: currentDay,
        mealType: selectedMealType,
        newItem: {
          'item': item['item'],
          'calories': item['calories'],
          'quantity': '1 serving',
          'description': item['description'],
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item['item']} added to your $selectedMealType!'),
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
