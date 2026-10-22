import 'dart:async';
import 'dart:math' as math;

import 'package:dadabhaitravel/view/pages/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  static const Color dark = Color(0xFF032C60);

  static const _totalDuration = Duration(milliseconds: 2200);
  static const _holdBeforeNav = Duration(milliseconds: 1300);

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF032C60),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: _totalDuration,
    )..forward();

    Timer(_totalDuration + _holdBeforeNav, _goToOnboarding);
  }

  void _goToOnboarding() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 550),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: .97,
                end: 1.0,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Animation<double> _fade(double start, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        start,
        end,
        curve: Curves.easeOut,
      ),
    );
  }

  Animation<Offset> _slide(
      double start,
      double end, {
        double dy = .16,
      }) {
    return Tween<Offset>(
      begin: Offset(0, dy),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          start,
          end,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final logoFade = _fade(0.00, 0.42);

    final logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.00,
        0.52,
        curve: Curves.easeOutBack,
      ),
    );

    final titleFade = _fade(0.28, 0.62);
    final titleSlide = _slide(0.28, 0.62);

    final subtitleFade = _fade(0.40, 0.72);
    final subtitleSlide = _slide(0.40, 0.72);

    final featureFade = _fade(0.52, 0.86);
    final featureSlide = _slide(
      0.52,
      0.86,
      dy: .20,
    );

    final footerFade = _fade(0.72, 1.00);

    return Scaffold(
      backgroundColor: dark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) {
              return Container(
                color: dark,
              );
            },
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(.02),
                  Colors.transparent,
                  Colors.black.withOpacity(.08),
                ],
                stops: const [
                  0,
                  .55,
                  1,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                16,
                24,
                20,
              ),
              child: Column(
                children: [
                  const Spacer(
                    flex: 4,
                  ),

                  // LOGO
                  FadeTransition(
                    opacity: logoFade,
                    child: ScaleTransition(
                      scale: logoScale,
                      child: _LogoMark(
                        size: size,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // TITLE
                  FadeTransition(
                    opacity: titleFade,
                    child: SlideTransition(
                      position: titleSlide,
                      child: Text(
                        'Your Journey Begins Here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                          size.width < 360 ? 24 : 28,
                          fontWeight:
                          FontWeight.w700,
                          height: 1.15,
                          letterSpacing: -.25,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 9,
                  ),

                  // SUB TITLE
                  FadeTransition(
                    opacity: subtitleFade,
                    child: SlideTransition(
                      position: subtitleSlide,
                      child: Text(
                        'Discover  •  Book  •  Explore',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                          Colors.white.withOpacity(.72),
                          fontSize:
                          size.width < 360 ? 13 : 15,
                          fontWeight:
                          FontWeight.w400,
                          letterSpacing: 1.15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // FLIGHTS / HOTELS / TOURS
                  FadeTransition(
                    opacity: featureFade,
                    child: SlideTransition(
                      position: featureSlide,
                      child: const Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          _SplashFeature(
                            icon:
                            Icons.flight_rounded,
                            title: 'Flights',
                          ),

                          SizedBox(
                            width: 34,
                          ),

                          _SplashFeature(
                            icon:
                            Icons.apartment_rounded,
                            title: 'Hotels',
                          ),

                          SizedBox(
                            width: 34,
                          ),

                          _SplashFeature(
                            icon:
                            Icons.location_on_rounded,
                            title: 'Tours',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(
                    flex: 8,
                  ),

                  // BOTTOM LOADER
                  FadeTransition(
                    opacity: footerFade,
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        const _AnimatedLoadingBar(),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          'Loading your next adventure...',
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                            color:
                            Colors.white.withOpacity(.86),
                            fontSize: 11.5,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 8,
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

class _LogoMark extends StatelessWidget {
  final Size size;

  const _LogoMark({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidth =
    math.min(
      size.width * .74,
      330.0,
    );

    final logoHeight =
        logoWidth * .38;

    return SizedBox(
      width: logoWidth,
      height: logoHeight,
      child: ColorFiltered(
        colorFilter:
        const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder:
              (_, __, ___) {
            return Center(
              child: Icon(
                Icons.flight_takeoff_rounded,
                color: Colors.white,
                size:
                logoHeight * .70,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SplashFeature
    extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SplashFeature({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,

            color:
            Colors.white.withOpacity(
              .035,
            ),

            border: Border.all(
              color:
              Colors.white.withOpacity(
                .75,
              ),
              width: 1.6,
            ),

            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withOpacity(
                  .08,
                ),
                blurRadius: 10,
                offset:
                const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),

          child: Icon(
            icon,
            size: 28,
            color: Colors.white,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        Text(
          title,
          style:
          const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight:
            FontWeight.w500,
            letterSpacing: .1,
          ),
        ),
      ],
    );
  }
}

class _AnimatedLoadingBar
    extends StatefulWidget {
  const _AnimatedLoadingBar();

  @override
  State<_AnimatedLoadingBar>
  createState() =>
      _AnimatedLoadingBarState();
}

class _AnimatedLoadingBarState
    extends State<_AnimatedLoadingBar>
    with
        SingleTickerProviderStateMixin {
  late final AnimationController
  _loadingController;

  @override
  void initState() {
    super.initState();

    _loadingController =
    AnimationController(
      vsync: this,
      duration:
      const Duration(
        milliseconds: 1500,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _loadingController.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return SizedBox(
      width: 145,
      height: 5,

      child: AnimatedBuilder(
        animation:
        _loadingController,

        builder:
            (_, __) {
          return ClipRRect(
            borderRadius:
            BorderRadius.circular(
              100,
            ),

            child: Stack(
              children: [
                Positioned.fill(
                  child:
                  Container(
                    color:
                    Colors.white.withOpacity(
                      .25,
                    ),
                  ),
                ),

                FractionallySizedBox(
                  widthFactor: .42,

                  alignment:
                  Alignment(
                    -1 +
                        (2 *
                            _loadingController.value),
                    0,
                  ),

                  child:
                  Container(
                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        100,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}