import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _logoFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Logo scale: starts small, grows to normal
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Logo fade in
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Text slide up + fade in
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Navigate to login after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF062A5A), // primary dark blue
              Color(0xFF0A3D7A),
              Color(0xFF0083DA), // primaryGradient blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              top: -80,
              right: -80,
              child: _buildDecorativeCircle(220, Colors.white.withAlpha(15)),
            ),
            Positioned(
              top: -30,
              right: -30,
              child: _buildDecorativeCircle(130, Colors.white.withAlpha(20)),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: _buildDecorativeCircle(280, Colors.white.withAlpha(10)),
            ),
            Positioned(
              bottom: 60,
              left: -40,
              child: _buildDecorativeCircle(150, Colors.white.withAlpha(18)),
            ),
            // Gold accent arc top-left
            Positioned(
              top: 80,
              left: -60,
              child: _buildDecorativeCircle(180, const Color(0xFFFFD230).withAlpha(25)),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(60),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFD230).withAlpha(80),
                            blurRadius: 40,
                            spreadRadius: 2,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icons/app_icon.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // School name
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        const Text(
                          'رياض ومدارس',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFD230),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'أنوار العُلى الدولية النموذجية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD230),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'بوابة أولياء الأمور',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom loading indicator
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFD230),
                        ),
                        backgroundColor: Colors.white.withAlpha(40),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'جاري التحميل...',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
