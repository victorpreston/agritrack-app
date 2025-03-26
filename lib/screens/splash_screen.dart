import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dashboard/dashboard_screen.dart';
import 'onboarding_screen.dart';
import '../theme/app_theme.dart';
import 'package:hugeicons/hugeicons.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Main fade animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Check session and navigate accordingly
    _checkUserSession();
  }

  // Check if user session exists and navigate accordingly
  Future<void> _checkUserSession() async {
    bool isLoggedIn = await AuthService().restoreSession();

    // Delay to ensure splash screen animations play
    await Future.delayed(const Duration(seconds: 6));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => isLoggedIn ? const DashboardScreen() : const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: theme.scaffoldBackgroundColor,
            child: Stack(
              children: [
                // Soil background
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight * 0.4),
                    painter: SoilPainter(isDarkMode: isDarkMode),
                  ),
                ),

                // Plant
                Positioned(
                  bottom: 140,
                  right: 170,
                  child: Image.asset(
                    'assets/splash/plant.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.9),
                  ),
                ),

                _buildClouds(isDarkMode),

                // Main content
                Positioned(
                  top: constraints.maxHeight * 0.22,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App Icon
                      FadeTransition(
                        opacity: _animation,
                        child: ScaleTransition(
                          scale: _animation,
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.lightGreen,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: const Icon(
                              Icons.eco,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // App name with enhanced effect
                      FadeTransition(
                        opacity: _animation,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.lightGreen,
                                AppTheme.primaryColor,
                              ],
                              stops: [0.0, 0.5, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(bounds);
                          },
                          child: Text(
                            'AgriTrack',
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Static tagline
                      Text(
                        'Smart Farming Solutions',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),

                // HugeIcons - static without animation
                Positioned(
                  top: constraints.maxHeight * 0.05,
                  right: constraints.maxWidth * 0.05,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedIrisScan,
                    size: 30,
                    color: AppTheme.primaryColor,
                  ),
                ),

                // Bottom tech icons
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Row(
                    children: [
                      FadeTransition(
                        opacity: _animation,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedAnalytics02,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      FadeTransition(
                        opacity: _animation,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedPlant02,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClouds(bool isDarkMode) {
    final cloudColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final darkCloudColor = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;

    return Stack(
      children: [
        Positioned(
          top: 40,
          left: 70,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedCloud,
            size: 60,
            color: cloudColor,
          ),
        ),
        Positioned(
          top: 30,
          left: 170,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedCloud,
            size: 70,
            color: darkCloudColor,
          ),
        ),
        Positioned(
          top: 50,
          right: 70,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedCloud,
            size: 65,
            color: cloudColor,
          ),
        ),
      ],
    );
  }
}

// Soil painter
class SoilPainter extends CustomPainter {
  final bool isDarkMode;

  SoilPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final soilBaseColor = isDarkMode
        ? const Color(0xFF3D2314)
        : const Color(0xFF8B4513);

    final soilDarkColor = isDarkMode
        ? const Color(0xFF2A1A0A)
        : const Color(0xFF654321);

    final spotColor = isDarkMode
        ? const Color(0xFF2A1A0A).withOpacity(0.4)
        : const Color(0xFF3D2314).withOpacity(0.3);

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          soilBaseColor.withOpacity(0.8),
          soilDarkColor,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.4);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.3, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(
        size.width * 0.25, size.height * 0.5, 0, size.height * 0.3);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final Random random = Random(42);
    final spotPaint = Paint()
      ..color = spotColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 100; i++) {
      final spotX = random.nextDouble() * size.width;
      final spotY = size.height * 0.4 + random.nextDouble() * (size.height * 0.6);
      final spotSize = random.nextDouble() * 4 + 2;

      canvas.drawCircle(Offset(spotX, spotY), spotSize, spotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SoilPainter oldDelegate) {
    return oldDelegate.isDarkMode != isDarkMode;
  }
}