import 'package:flutter/material.dart';
import 'dart:async';
import '../auth/register_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _splitAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Logo animation (ease in from outside to center)
    _logoAnimation = Tween<double>(
      begin: 2.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Split animation
    _splitAnimation = Tween<double>(
      begin: -10.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    // Start animation after a brief delay
    Timer(const Duration(seconds: 1), () {
      _controller.forward();
    });

    // Navigate to main screen after animations
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Timer(const Duration(milliseconds: 500), () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const RegisterPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                // Fade transition
                const begin = 0.0;
                const end = 1.0;
                var fade = Tween(begin: begin, end: end).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ),
                );

                // Scale transition
                var scale = Tween(begin: 0.5, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ),
                );

                // Slide transition
                var slide = Tween(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ),
                );

                return FadeTransition(
                  opacity: fade,
                  child: SlideTransition(
                    position: slide,
                    child: ScaleTransition(
                      scale: scale,
                      child: child,
                    ),
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        });
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
      backgroundColor: const Color(0xFF62DFFE),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Left split panel
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: MediaQuery.of(context).size.width / 2,
                child: Transform.translate(
                  offset: Offset(
                      -MediaQuery.of(context).size.width *
                          _splitAnimation.value,
                      0),
                  child: Container(
                    color: const Color(0xFF62DFFE),
                  ),
                ),
              ),
              // Right split panel
              Positioned(
                left: MediaQuery.of(context).size.width / 2,
                top: 0,
                bottom: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(
                      MediaQuery.of(context).size.width * _splitAnimation.value,
                      0),
                  child: Container(
                    color: const Color(0xFF62DFFE),
                  ),
                ),
              ),
              // Centered logo
              Center(
                child: Transform.scale(
                  scale: _logoAnimation.value,
                  child: Image.asset(
                    'assets/images/Logo_Blue.png',
                    width: 200,
                    height: 200,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
