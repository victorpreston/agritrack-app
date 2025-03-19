import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'disease_detection_tab.dart';
import 'market_tab.dart';
import 'profile_tab.dart';
import 'package:flutter/material.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                size: 24,
              ),
              activeIcon: Icon(
                Icons.home,
                size: 24,
                color: Colors.white,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.document_scanner_outlined,
                size: 24,
              ),
              activeIcon: Icon(
                Icons.document_scanner,
                size: 24,
                color: Colors.white,
              ),
              label: 'Detect',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.trending_up_outlined,
                size: 24,
              ),
              activeIcon: Icon(
                Icons.trending_up,
                size: 24,
                color: Colors.white,
              ),
              label: 'Market',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
                size: 24,
              ),
              activeIcon: Icon(
                Icons.person,
                size: 24,
                color: Colors.white,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show quick actions menu
          _showQuickActionsMenu();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
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
                    Icons.document_scanner_outlined,
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
                    Icons.shopping_bag_outlined,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('Shop Products'),
                subtitle: const Text('Browse agricultural products'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to shop screen
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.task_outlined,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('Add Task'),
                subtitle: const Text('Create a new farming task'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to add task screen
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
                subtitle: const Text('Check your farm performance'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to analytics screen
                },
              ),
            ],
          ),
        );
      },
    );
  }
}