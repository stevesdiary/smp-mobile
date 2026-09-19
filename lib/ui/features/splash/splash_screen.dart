import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Spring curve for scale (0.8 -> 1.0)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const ElasticOutCurve(0.8), // Gives a nice spring effect
      ),
    );

    // Fade to white at the end of the duration (1.0 -> 0.0 for the logo)
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      // Route after the animation finishes
      if (mounted) {
        context.go('/login');
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
    // Deep Navy background from the theme
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: primaryColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Fade to system background before routing
          final backgroundColor = Color.lerp(
            primaryColor,
            Theme.of(context).scaffoldBackgroundColor,
            _opacityAnimation.value == 0.0 ? 1.0 : 0.0, // Fade out the navy background at the very end
          );
          
          return Container(
            color: _opacityAnimation.value < 0.2 ? backgroundColor : primaryColor,
            child: Center(
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 80,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
