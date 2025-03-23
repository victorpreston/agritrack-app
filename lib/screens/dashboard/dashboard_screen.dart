import 'package:hugeicons/hugeicons.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../tasks/add_task_screen.dart';
import '../treatments/treatment_shop_screen.dart';
import 'home_tab.dart';
import 'disease_detection_tab.dart';
import 'market_tab.dart';
import 'profile_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const DiseaseDetectionTab(),
    const MarketTab(),
    const ProfileTab(),
  ];

  final List<String> _svgIcons = [
    'assets/navbar/home.svg',
    'assets/navbar/scanner.svg',
    'assets/navbar/market.svg',
    'assets/navbar/user.svg',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Get appropriate background color based on theme
    final backgroundColor = isDarkMode
        ? theme.scaffoldBackgroundColor
        : Colors.white;

    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: List.generate(
          _svgIcons.length,
              (index) => SvgPicture.asset(
            _svgIcons[index],
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
        color: theme.colorScheme.primary,
        buttonBackgroundColor: theme.colorScheme.primary,
        backgroundColor: backgroundColor,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show quick actions menu
          _showQuickActionsMenu();
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(
          HugeIcons.strokeRoundedMore,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showQuickActionsMenu() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    HugeIcons.strokeRoundedSearchFocus,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text('Scan Crop Disease', style: theme.textTheme.titleMedium),
                subtitle: Text('Take a photo to detect diseases', style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    HugeIcons.strokeRoundedShoppingBagAdd,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text('Shop Products', style: theme.textTheme.titleMedium),
                subtitle: Text('Browse agricultural products', style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TreatmentShopScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    HugeIcons.strokeRoundedNoteAdd,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text('Add Task', style: theme.textTheme.titleMedium),
                subtitle: Text('Create a new farming task', style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTaskScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.analytics_outlined,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text('View Analytics', style: theme.textTheme.titleMedium),
                subtitle: Text('Check Market Analytics', style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarketTab(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}