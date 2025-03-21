import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/user_profile.dart';
import '../models/crop.dart';
import '../screens/dashboard/market_tab.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/tasks/tasks_screen.dart';
import '../theme/app_theme.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/disease_detection_tab.dart';
import '../screens/treatments/treatment_shop_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/auth/login_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final UserProfileService _profileService = UserProfileService();
  final SupabaseClient _supabase = Supabase.instance.client;
  UserProfile? _userProfile;
  List<Crop> _userCrops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        // Load user profile
        final profile = await _profileService.getUserProfile(userId, context);

        if (profile != null) {
          // Load user crops
          final cropsResponse = await _supabase
              .from('crops')
              .select()
              .eq('farm_id', profile.farmId);

          final crops = (cropsResponse as List)
              .map((crop) => Crop.fromJson(crop))
              .toList();

          setState(() {
            _userProfile = profile;
            _userCrops = crops;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Handle error silently
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getCropsDescription() {
    if (_userCrops.isEmpty) {
      return 'No crops added yet';
    }

    // Get unique crop types
    final cropTypes = _userCrops.map((crop) => crop.type).toSet().toList();

    if (cropTypes.length <= 2) {
      return cropTypes.join(' & ') + ' Farmer';
    } else {
      return 'Mixed Crop Farmer';
    }
  }

  Widget _buildUserProfileHeader() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    final profile = _userProfile;
    if (profile == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
        ),
        child: const Center(
          child: Text(
            'Profile not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Get first letters of the name for avatar
    final nameInitials = profile.fullName.isNotEmpty
        ? profile.fullName.split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() : '').join('').substring(0, min(2, profile.fullName.split(' ').length))
        : 'U';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              profile.profilePicture.isNotEmpty
                  ? CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(profile.profilePicture),
              )
                  : CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  nameInitials,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getCropsDescription(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '${profile.subscription} Member',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Container(
        color: theme.colorScheme.background,
        child: Column(
          children: [
            // Drawer Header with user info
            _buildUserProfileHeader(),

            // Drawer Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.qr_code_scanner,
                    title: 'Disease Detection',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DiseaseDetectionTab(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Shop Treatments',
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
                  _buildDrawerItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.task_outlined,
                    title: 'My Tasks',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TasksScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.bar_chart_outlined,
                    title: 'Analytics',
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
                  _buildDrawerItem(
                    context,
                    icon: Icons.shopping_cart_outlined,
                    title: 'My Orders',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrdersScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to help screen
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () async {
                      await AuthService().signOut(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            // App version at bottom
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium!.color,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        Color? textColor,
        Color? iconColor,
      }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        size: 24,
        color: iconColor ?? theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? theme.textTheme.bodyLarge!.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

// Helper function to find minimum of two integers
int min(int a, int b) {
  return a < b ? a : b;
}