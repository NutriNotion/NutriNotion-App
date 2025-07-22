import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutrinotion_app/backend/providers/auth_provider.dart';
import 'package:nutrinotion_app/backend/providers/user_provider.dart';
import 'package:nutrinotion_app/const/custom_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedMealType = 'Breakfast';

  // Sample mess menu data - you can replace this with actual data from your backend
  final Map<String, List<Map<String, dynamic>>> _messMenu = {
    'Breakfast': [
      {
        'name': 'Idli Sambar',
        'description': 'Steamed rice cakes with lentil curry',
        'calories': 180,
        'protein': 6.0,
        'carbs': 32.0,
        'fat': 2.5,
      },
      {
        'name': 'Poha',
        'description': 'Flattened rice with vegetables and spices',
        'calories': 220,
        'protein': 4.5,
        'carbs': 45.0,
        'fat': 3.0,
      },
      {
        'name': 'Upma',
        'description': 'Semolina porridge with vegetables',
        'calories': 200,
        'protein': 5.0,
        'carbs': 38.0,
        'fat': 4.0,
      },
      {
        'name': 'Aloo Paratha',
        'description': 'Potato stuffed flatbread with yogurt',
        'calories': 320,
        'protein': 8.0,
        'carbs': 52.0,
        'fat': 10.0,
      },
    ],
    'Lunch': [
      {
        'name': 'Dal Rice',
        'description': 'Lentil curry with steamed rice',
        'calories': 350,
        'protein': 12.0,
        'carbs': 65.0,
        'fat': 5.0,
      },
      {
        'name': 'Chicken Curry',
        'description': 'Spiced chicken curry with rice',
        'calories': 450,
        'protein': 35.0,
        'carbs': 40.0,
        'fat': 18.0,
      },
      {
        'name': 'Vegetable Biryani',
        'description': 'Aromatic rice with mixed vegetables',
        'calories': 380,
        'protein': 8.0,
        'carbs': 70.0,
        'fat': 8.0,
      },
      {
        'name': 'Rajma Chawal',
        'description': 'Kidney bean curry with rice',
        'calories': 420,
        'protein': 15.0,
        'carbs': 68.0,
        'fat': 8.0,
      },
      {
        'name': 'Paneer Sabzi',
        'description': 'Cottage cheese curry with roti',
        'calories': 390,
        'protein': 18.0,
        'carbs': 35.0,
        'fat': 20.0,
      },
    ],
    'Dinner': [
      {
        'name': 'Roti Sabzi',
        'description': 'Wheat flatbread with vegetable curry',
        'calories': 280,
        'protein': 10.0,
        'carbs': 45.0,
        'fat': 8.0,
      },
      {
        'name': 'Fish Curry',
        'description': 'Spiced fish curry with rice',
        'calories': 340,
        'protein': 28.0,
        'carbs': 25.0,
        'fat': 15.0,
      },
      {
        'name': 'Mixed Dal',
        'description': 'Mixed lentil curry with rice',
        'calories': 320,
        'protein': 14.0,
        'carbs': 55.0,
        'fat': 6.0,
      },
      {
        'name': 'Egg Curry',
        'description': 'Boiled eggs in spiced gravy',
        'calories': 300,
        'protein': 20.0,
        'carbs': 15.0,
        'fat': 18.0,
      },
    ],
    'Snacks': [
      {
        'name': 'Samosa',
        'description': 'Deep fried pastry with potato filling',
        'calories': 150,
        'protein': 3.0,
        'carbs': 18.0,
        'fat': 8.0,
      },
      {
        'name': 'Bhel Puri',
        'description': 'Puffed rice snack with chutneys',
        'calories': 120,
        'protein': 2.5,
        'carbs': 22.0,
        'fat': 3.0,
      },
      {
        'name': 'Pakora',
        'description': 'Deep fried vegetable fritters',
        'calories': 180,
        'protein': 4.0,
        'carbs': 15.0,
        'fat': 12.0,
      },
      {
        'name': 'Chai',
        'description': 'Spiced milk tea',
        'calories': 80,
        'protein': 2.0,
        'carbs': 12.0,
        'fat': 3.0,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'NutriNotion',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildSidebar(context),
      body: Column(
        children: [
          // Welcome Section
          _buildWelcomeSection(),
          
          // Meal Type Selector
          _buildMealTypeSelector(),
          
          // Menu Items
          Expanded(
            child: _buildMenuItems(),
          ),
        ],
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
                          userProvider.getUserInitials(),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Text(
                'Welcome back, ${authProvider.userDisplayName?.split(' ').first ?? 'User'}!',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to eat today?',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          // Quick stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Today\'s Calories', '1,420', Icons.local_fire_department),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Meals Logged', '2', Icons.restaurant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: _messMenu.keys.map((mealType) {
            final isSelected = _selectedMealType == mealType;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMealType = mealType;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey.shade300,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    mealType,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    final items = _messMenu[_selectedMealType] ?? [];
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildMenuItem(item);
      },
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Placeholder for food image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.restaurant,
              color: primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          
          // Food details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'],
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Nutrition info
                Row(
                  children: [
                    _buildNutritionChip('${item['calories']} cal', Icons.local_fire_department),
                    const SizedBox(width: 8),
                    _buildNutritionChip('${item['protein']}g protein', Icons.fitness_center),
                  ],
                ),
              ],
            ),
          ),
          
          // Add button
          GestureDetector(
            onTap: () {
              _addToNutritionTracker(item);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
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
    // TODO: Add to nutrition provider
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
                  Navigator.pushReplacementNamed(context, '/login');
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