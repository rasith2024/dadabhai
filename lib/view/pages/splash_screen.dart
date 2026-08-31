import 'dart:async';

import 'package:dadabhaitravel/view/pages/dashboard.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _contentController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  static const Color dark = Color(0xff0F4C81);
  static const Color primary = Color(0xff1C7ED6);
  static const Color light = Color(0xff4DABF7);

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = Tween<double>(
      begin: .72,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, .20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    _logoController.forward();

    Future.delayed(
      const Duration(milliseconds: 450),
          () {
        if (mounted) {
          _contentController.forward();
        }
      },
    );

    Timer(
      const Duration(seconds: 4),
          () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, __) =>
            const DashboardScreen(),
            transitionDuration:
            const Duration(milliseconds: 650),
            transitionsBuilder:
                (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background travel image
          Image.asset(
            'assets/images/splash_bg.jpg',
            fit: BoxFit.cover,
          ),

          // Dark blue overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  dark.withOpacity(.45),
                  dark.withOpacity(.58),
                  dark.withOpacity(.92),
                ],
                stops: const [
                  0,
                  .45,
                  1,
                ],
              ),
            ),
          ),

          // Decorative glow
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: light.withOpacity(.12),
              ),
            ),
          ),

          Positioned(
            bottom: 130,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(.10),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Column(
                children: [
                  const Spacer(),

                  // Logo
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.96),
                          borderRadius:
                          BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.18),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          const Text(
                            'Explore More.\nTravel Better.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.4,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Flights, holidays, tours and unforgettable experiences — all in one place.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                              Colors.white.withOpacity(.82),
                              fontSize: 13,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 22),

                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: const [
                              _SplashChip(
                                icon:
                                Icons.flight_takeoff_rounded,
                                text: 'Flights',
                              ),
                              _SplashChip(
                                icon:
                                Icons.beach_access_rounded,
                                text: 'Holidays',
                              ),
                              _SplashChip(
                                icon:
                                Icons.explore_rounded,
                                text: 'Tours',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  FadeTransition(
                    opacity: _contentFade,
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          'Preparing your journey...',
                          style: TextStyle(
                            color:
                            Colors.white.withOpacity(.68),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Dadabhai Travel LLC',
                          style: TextStyle(
                            color:
                            Colors.white.withOpacity(.45),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SplashChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}