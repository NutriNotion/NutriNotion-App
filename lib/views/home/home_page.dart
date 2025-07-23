import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrinotion_app/backend/providers/auth_provider.dart';
import 'package:nutrinotion_app/backend/providers/user_provider.dart';
import 'package:nutrinotion_app/backend/services/mess_service.dart';
import 'package:nutrinotion_app/const/custom_colors.dart';
import 'package:nutrinotion_app/const/page_transitions.dart';
import 'package:nutrinotion_app/views/auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MessService _messService = MessService();
  
  // Track completed individual items
  final Set<String> _completedItems = <String>{};
  
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

  // Get appropriate icon for food items
  IconData _getFoodIcon(String foodName) {
    final name = foodName.toLowerCase();
    if (name.contains('rice') || name.contains('biryani') || name.contains('dal')) {
      return Icons.rice_bowl;
    } else if (name.contains('roti') || name.contains('paratha') || name.contains('bread')) {
      return Icons.bakery_dining;
    } else if (name.contains('curry') || name.contains('sabzi') || name.contains('sambar')) {
      return Icons.soup_kitchen;
    } else if (name.contains('chai') || name.contains('tea') || name.contains('coffee')) {
      return Icons.local_cafe;
    } else if (name.contains('samosa') || name.contains('pakora') || name.contains('puri')) {
      return Icons.fastfood;
    } else if (name.contains('idli') || name.contains('upma') || name.contains('poha')) {
      return Icons.breakfast_dining;
    } else if (name.contains('paneer') || name.contains('chicken') || name.contains('egg') || name.contains('fish')) {
      return Icons.dinner_dining;
    } else {
      return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  
                  // Breakfast Section
                  _buildMealSection('Breakfast', [
                    {'name': 'Idli Sambar', 'quantity': '3 pieces', 'calories': 180},
                    {'name': 'Coconut Chutney', 'quantity': '2 tbsp', 'calories': 45},
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Lunch Section
                  _buildMealSection('Lunch', [
                    {'name': 'Dal Rice', 'quantity': '1 bowl', 'calories': 350},
                    {'name': 'Mixed Vegetables', 'quantity': '1 serving', 'calories': 120},
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Snacks Section
                  _buildMealSection('Snacks', [
                    {'name': 'Banana', 'quantity': '1 medium', 'calories': 105},
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Dinner Section
                  _buildMealSection('Dinner', [
                    {'name': 'Roti', 'quantity': '2 pieces', 'calories': 140},
                    {'name': 'Paneer Sabzi', 'quantity': '1 serving', 'calories': 250},
                  ]),
                  
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
                          'A',
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
                // Navigate to profile page
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
                icon: const Icon(Icons.menu, color: Color.fromARGB(255, 31, 31, 31)),
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
          // const SizedBox(height: 20),
          // Greeting
          // Consumer2<AuthProvider, UserProvider>(
          //   builder: (context, authProvider, userProvider, child) {
          //     final timeOfDay = DateTime.now().hour;
          //     String greeting = 'Good Evening';
              
          //     if (timeOfDay >= 5 && timeOfDay < 12) {
          //       greeting = 'Good Morning';
          //     } else if (timeOfDay >= 12 && timeOfDay < 17) {
          //       greeting = 'Good Afternoon';
          //     } else {
          //       greeting = 'Good Evening';
          //     }
              
          //     final userName = authProvider.userDisplayName?.split(' ').first ?? 'User';

          //     return Text(
          //       '$greeting, $userName!',
          //       style: GoogleFonts.lato(
          //         fontSize: 20,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.black87,
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }



  Widget _buildMealSection(String mealType, List<Map<String, dynamic>> items) {
    int totalCalories = items.fold(0, (sum, item) => sum + (item['calories'] as int));
    bool isTimePassed = _isMealTimePassed(mealType);
    
    // Check if all items in this meal are completed
    bool allItemsCompleted = items.every((item) => 
        _completedItems.contains('${mealType.toLowerCase()}_${item['name']}'));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal type header with + icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              mealType.toUpperCase(),
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: allItemsCompleted ? Colors.grey : const Color.fromARGB(255, 27, 27, 27),
                letterSpacing: 1.2
              ),
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
          final itemKey = '${mealType.toLowerCase()}_${item['name']}';
          final isItemCompleted = _completedItems.contains(itemKey);
          final shouldBeGrayedOut = isItemCompleted || isTimePassed;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: shouldBeGrayedOut ? Colors.grey[100] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: shouldBeGrayedOut ? Colors.grey.shade300 : Colors.grey.shade200
              ),
              boxShadow: shouldBeGrayedOut ? [] : [
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
                    Icons.restaurant,
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
                        item['name'],
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: shouldBeGrayedOut ? Colors.grey[600] : Colors.black87,
                          decoration: isItemCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item['quantity']} • ${item['calories']} kcal',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: shouldBeGrayedOut ? Colors.grey[500] : Colors.grey[600],
                          decoration: isItemCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isItemCompleted && !isTimePassed)
                  GestureDetector(
                    onTap: () => _toggleItemCompletion(itemKey, item['name'], mealType),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        
        // Total calories for this meal
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: allItemsCompleted || isTimePassed
                ? LinearGradient(
                    colors: [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : LinearGradient(
                    colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: allItemsCompleted || isTimePassed
                  ? Colors.grey.withOpacity(0.5) 
                  : primaryColor.withOpacity(0.3)
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$mealType Total:',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: allItemsCompleted || isTimePassed ? Colors.grey[600] : primaryColor,
                  decoration: allItemsCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              Text(
                '$totalCalories kcal',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: allItemsCompleted || isTimePassed ? Colors.grey[600] : primaryColor,
                  decoration: allItemsCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCaloriesSummary() {
    const totalCalories = 1190; // Sum of all meals
    const targetCalories = 1400; // This should come from user's profile
    final progress = totalCalories / targetCalories;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Progress',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Total Calories: $totalCalories / $targetCalories kcal',
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress > 1.0 ? 1.0 : progress,
              child: Container(
                decoration: BoxDecoration(
                  color: progress > 1.0 ? Colors.orange : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% of daily goal',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  progress > 1.0 ? 'Over Target' : 'On Track',
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
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

  void _toggleItemCompletion(String itemKey, String itemName, String mealType) {
    setState(() {
      if (_completedItems.contains(itemKey)) {
        _completedItems.remove(itemKey);
      } else {
        _completedItems.add(itemKey);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _completedItems.contains(itemKey)
              ? '$itemName from $mealType marked as completed!'
              : '$itemName from $mealType marked as incomplete!',
        ),
        backgroundColor: _completedItems.contains(itemKey)
            ? Colors.green
            : Colors.orange,
        duration: const Duration(seconds: 2),
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

  Widget _buildMenuList(String mealType, [ScrollController? scrollController]) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _messService.getMenuStream("wednesday").cast<DocumentSnapshot>(),
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
                  'Failed to load menu',
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
                    // Force rebuild the StreamBuilder by changing the stream
                    setState(() {});
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
        
        // Convert raw items to list of strings
        List<String> itemNames = [];
        if (itemsRaw is List) {
          itemNames = itemsRaw.cast<String>();
        }

        if (itemNames.isEmpty) {
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
        
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: itemNames.length,
          itemBuilder: (context, index) {
            final itemName = itemNames[index];
            
            // Create a simple item map from the string name
            final item = {
              'name': itemName,
              'description': 'Delicious $itemName prepared fresh',
              'calories': 200, // Default calories
              'isVegetarian': !itemName.toLowerCase().contains('chicken') && 
                             !itemName.toLowerCase().contains('fish') && 
                             !itemName.toLowerCase().contains('egg') &&
                             !itemName.toLowerCase().contains('mutton'),
              'category': 'Indian',
            };
            
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
                          colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
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
                                  item['name'] as String,
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
                            item['description'] as String? ?? 'No description available',
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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                              // if (item['category'] != null && item['category'].toString().isNotEmpty) ...[
                              //   const SizedBox(width: 8),
                              //   Container(
                              //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              //     decoration: BoxDecoration(
                              //       color: Colors.grey[100],
                              //       borderRadius: BorderRadius.circular(12),
                              //     ),
                              //     child: Text(
                              //       item['category'] as String,
                              //       style: GoogleFonts.lato(
                              //         fontSize: 10,
                              //         fontWeight: FontWeight.w500,
                              //         color: Colors.grey[600],
                              //       ),
                              //     ),
                              //   ),
                              // ],
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
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        onPressed: () {
                          Navigator.pop(context);
                          _addToNutritionTracker(item);
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

  // Optional: Method for building menu list for specific days (future use)
  // ignore: unused_element
  Widget _buildMenuListForDay(String mealType, String dayOfWeek, [ScrollController? scrollController]) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _messService.getMenuStream(dayOfWeek).cast<DocumentSnapshot>(),
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
                  'Failed to load menu for ${dayOfWeek[0].toUpperCase()}${dayOfWeek.substring(1)}',
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
                    setState(() {});
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
        
        // Convert raw items to list of strings
        List<String> itemNames = [];
        if (itemsRaw is List) {
          itemNames = itemsRaw.cast<String>();
        }
        
        if (itemNames.isEmpty) {
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
                  'No $mealType items available for ${dayOfWeek[0].toUpperCase()}${dayOfWeek.substring(1)}',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: itemNames.length,
          itemBuilder: (context, index) {
            final itemName = itemNames[index];
            
            // Create a simple item map from the string name
            final item = {
              'name': itemName,
              'description': 'Delicious $itemName prepared fresh',
              'calories': 200, // Default calories
              'isVegetarian': !itemName.toLowerCase().contains('chicken') && 
                             !itemName.toLowerCase().contains('fish') && 
                             !itemName.toLowerCase().contains('egg') &&
                             !itemName.toLowerCase().contains('mutton'),
              'category': 'Indian',
            };
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
                          colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
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
                              if (item['isVegetarian'] == true)
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: const Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                    size: 8,
                                  ),
                                )
                              else
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: const Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                    size: 8,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['description'] as String? ?? 'No description available',
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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                              if (item['category'] != null && item['category'].toString().isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item['category'] as String,
                                    style: GoogleFonts.lato(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
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
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        onPressed: () {
                          Navigator.pop(context);
                          _addToNutritionTracker(item);
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

  void _addToNutritionTracker(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to nutrition tracker!'),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
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
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
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