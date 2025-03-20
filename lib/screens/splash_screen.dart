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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: Colors.white,
            child: Stack(
              children: [

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight * 0.4),
                    painter: SoilPainter(),
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

                _buildClouds(),

                // Main content
                Positioned(
                  top: constraints.maxHeight * 0.22,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      FadeTransition(
                        opacity: _animation,
                        child: ScaleTransition(
                          scale: _animation,
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  Colors.green.shade300,
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
                            return LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                Colors.green.shade300,
                                AppTheme.primaryColor,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(bounds);
                          },
                          child: Text(
                            'AgriTrack',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
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

  Widget _buildClouds() {
    return Stack(
      children: [
        Positioned(
          top: 40,
          left: 70,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedCloud,
            size: 60,
            color: Colors.grey.shade300,
          ),
        ),
        Positioned(
          top: 30,
          left: 170,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedCloud,
            size: 70,
            color: Colors.grey.shade400,
          ),
        ),
        Positioned(
          top: 50,
          right: 70,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedCloud,
            size: 65,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}

// Soil painter
class SoilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF8B4513).withOpacity(0.8),
          const Color(0xFF654321),
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
      ..color = const Color(0xFF3D2314).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 100; i++) {
      final spotX = random.nextDouble() * size.width;
      final spotY = size.height * 0.4 + random.nextDouble() * (size.height * 0.6);
      final spotSize = random.nextDouble() * 4 + 2;

      canvas.drawCircle(Offset(spotX, spotY), spotSize, spotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
