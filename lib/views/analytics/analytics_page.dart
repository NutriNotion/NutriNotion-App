import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../backend/providers/auth_provider.dart';
import '../../backend/providers/user_provider.dart';
import '../../backend/services/calorie_tracking_service.dart';
import '../../const/custom_colors.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final CalorieTrackingService _calorieService = CalorieTrackingService();
  Map<String, int> _calorieData = {};
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();
  int _targetCalories = 1400;
  int _totalDaysTargetMet = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (authProvider.userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user's calorie target
      await userProvider.loadFromFirestore(authProvider.userId!);
      _targetCalories = userProvider.user.calorieTargetPerDay ?? 1400;

      // Get calorie data for the selected month
      await _loadMonthData();
    } catch (e) {
      print('Error loading analytics data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMonthData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userId == null) return;

    // Get start and end dates for the month
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    try {
      final data = await _calorieService.getCalorieIntakeRange(
        authProvider.userId!,
        startDate,
        endDate,
      );

      setState(() {
        _calorieData = data;
      });

      _calculateStats();
    } catch (e) {
      print('Error loading month data: $e');
    }
  }

  void _calculateStats() {
    _totalDaysTargetMet = 0;
    _currentStreak = 0;
    _longestStreak = 0;
    int tempStreak = 0;

    // Get all days in the current month up to today
    final now = DateTime.now();
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = _selectedMonth.month == now.month && _selectedMonth.year == now.year
        ? now
        : DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    List<DateTime> daysToCheck = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      daysToCheck.add(startDate.add(Duration(days: i)));
    }

    // Calculate stats
    bool isCurrentStreakActive = true;
    for (int i = daysToCheck.length - 1; i >= 0; i--) {
      final date = daysToCheck[i];
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final calories = _calorieData[dateStr] ?? 0;
      final targetMet = calories >= _targetCalories;

      if (targetMet) {
        _totalDaysTargetMet++;
        tempStreak++;
        
        if (isCurrentStreakActive) {
          _currentStreak++;
        }
        
        if (tempStreak > _longestStreak) {
          _longestStreak = tempStreak;
        }
      } else {
        if (isCurrentStreakActive) {
          isCurrentStreakActive = false;
        }
        tempStreak = 0;
      }
    }
  }

  Color _getIntensityColor(int calories) {
    if (calories == 0) {
      return Colors.grey[200]!;
    }
    
    final percentage = calories / _targetCalories;
    if (percentage >= 1.0) {
      return primaryColor; // Dark color for target met
    } else if (percentage >= 0.8) {
      return primaryColor.withOpacity(0.7);
    } else if (percentage >= 0.6) {
      return primaryColor.withOpacity(0.5);
    } else if (percentage >= 0.4) {
      return primaryColor.withOpacity(0.3);
    } else {
      return primaryColor.withOpacity(0.1);
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
          'Analytics',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(),
                  const SizedBox(height: 14),
                  _buildMonthSelector(),
                  const SizedBox(height: 14),
                  _buildCalendarGrid(),
                  const SizedBox(height: 14),
                  _buildLegend(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _buildStatCard(
            'Target\nMet',
            '$_totalDaysTargetMet',
            'days this month',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 6,
          child: _buildStatCard(
            'Current Streak',
            '$_currentStreak',
            'consecutive days',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 5,
          child: _buildStatCard(
            'Best Streak',
            '$_longestStreak',
            'days record',
            Icons.emoji_events,
            primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          // Text(
          //   subtitle,
          //   style: GoogleFonts.lato(
          //     fontSize: 10,
          //     color: Colors.grey[600],
          //   ),
          //   textAlign: TextAlign.center,
          // ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
              });
              _loadMonthData();
            },
            icon: Icon(Icons.chevron_left, color: primaryColor),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            onPressed: _selectedMonth.isBefore(DateTime(DateTime.now().year, DateTime.now().month))
                ? () {
                    setState(() {
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                    });
                    _loadMonthData();
                  }
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: _selectedMonth.isBefore(DateTime(DateTime.now().year, DateTime.now().month))
                  ? primaryColor
                  : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Calorie Target Achievement',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildWeekDaysHeader(),
          const SizedBox(height: 12),
          _buildCalendarDays(),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) => 
        SizedBox(
          width: 32,
          child: Text(
            day,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildCalendarDays() {
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    // Find the Monday of the week containing the first day
    final firstMonday = startDate.subtract(Duration(days: (startDate.weekday - 1) % 7));
    
    final weeks = <Widget>[];
    DateTime currentWeekStart = firstMonday;
    
    while (currentWeekStart.isBefore(endDate) || currentWeekStart.month == _selectedMonth.month) {
      final weekDays = <Widget>[];
      
      for (int i = 0; i < 7; i++) {
        final day = currentWeekStart.add(Duration(days: i));
        final isCurrentMonth = day.month == _selectedMonth.month;
        final dateStr = DateFormat('yyyy-MM-dd').format(day);
        final calories = _calorieData[dateStr] ?? 0;
        final isFutureDate = day.isAfter(DateTime.now());
        
        weekDays.add(
          Tooltip(
            message: isCurrentMonth && !isFutureDate
                ? '${DateFormat('MMM d').format(day)}\n$calories / $_targetCalories kcal'
                : '',
            child: Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isCurrentMonth && !isFutureDate
                    ? _getIntensityColor(calories)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: isCurrentMonth && !isFutureDate
                    ? null
                    : Border.all(color: Colors.grey[300]!, width: 0.5),
              ),
              child: isCurrentMonth
                  ? Center(
                      child: Text(
                        '${day.day}',
                        style: GoogleFonts.lato(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isFutureDate
                              ? Colors.grey[400]
                              : (calories >= _targetCalories
                                  ? Colors.white
                                  : Colors.black87),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        );
      }
      
      weeks.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays,
        ),
      );
      
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }
    
    return Column(children: weeks);
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Less',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                final colors = [
                  Colors.grey[200]!,
                  primaryColor.withOpacity(0.3),
                  primaryColor.withOpacity(0.5),
                  primaryColor.withOpacity(0.7),
                  primaryColor,
                ];
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                'More',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Target achieved ($_targetCalories+ kcal)',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
