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

  // Paths to your SVG files - update these with your actual file paths
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
        color: Theme.of(context).colorScheme.primary,
        buttonBackgroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show quick actions menu
          _showQuickActionsMenu();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          HugeIcons.strokeRoundedMore,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showQuickActionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    HugeIcons.strokeRoundedSearchFocus,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('Scan Crop Disease'),
                subtitle: const Text('Take a photo to detect diseases'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedIndex = 1; // Navigate to disease detection tab
                  });
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    HugeIcons.strokeRoundedShoppingBagAdd,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('Shop Products'),
                subtitle: const Text('Browse agricultural products'),
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
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    HugeIcons.strokeRoundedNoteAdd,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('Add Task'),
                subtitle: const Text('Create a new farming task'),
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
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.analytics_outlined,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('View Analytics'),
                subtitle: const Text('Check Market Analytics'),
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