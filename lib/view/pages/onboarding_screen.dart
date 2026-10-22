import 'package:dadabhaitravel/view/pages/dashboard.dart';
import 'package:flutter/material.dart';

/// Three-slide onboarding flow shown once, right after the splash screen.
/// Logic/navigation is unchanged. UI is redesigned to match the splash
/// background and feel more premium/native.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingSlideData {
  final IconData icon;
  final String title;
  final String description;
  final Color accent;

  const _OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color dark = Color(0xff0A3D66);

  final _pageController = PageController();
  int _page = 0;

  static const _slides = [
    _OnboardingSlideData(
      icon: Icons.explore_rounded,
      title: 'Discover Amazing\nDestinations',
      description:
      'Browse handpicked spots around the world and find your next getaway in seconds.',
      accent: Color(0xff4DABF7),
    ),
    _OnboardingSlideData(
      icon: Icons.flight_takeoff_rounded,
      title: 'Book Flights &\nHotels Easily',
      description:
      'Compare prices, pick your seat and lock in a room — all from one simple screen.',
      accent: Color(0xffFFD166),
    ),
    _OnboardingSlideData(
      icon: Icons.beach_access_rounded,
      title: 'Unforgettable\nExperiences Await',
      description:
      'Tours, activities and local favorites curated just for how you like to travel.',
      accent: Color(0xff63E6BE),
    ),
  ];

  bool get _isLastPage => _page == _slides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLastPage) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const DashboardScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: .97, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: dark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Same background image used by splash screen.
          Image.asset(
            'assets/images/bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => Container(color: dark),
          ),

          // Soft overlay keeps content readable but preserves the image.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(.05),
                  Colors.black.withOpacity(.02),
                  Colors.black.withOpacity(.18),
                ],
                stops: const [0, .45, 1],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top area / Skip
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        opacity: _isLastPage ? 0 : 1,
                        child: IgnorePointer(
                          ignoring: _isLastPage,
                          child: TextButton(
                            onPressed: _finish,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              backgroundColor: Colors.white.withOpacity(.10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(.18),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) {
                      return _SlidePage(
                        data: _slides[i],
                        pageIndex: i,
                        screenSize: size,
                      );
                    },
                  ),
                ),

                // Dots + bottom CTA area
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                  child: _BottomPanel(
                    page: _page,
                    count: _slides.length,
                    isLast: _isLastPage,
                    accent: _slides[_page].accent,
                    onNext: _next,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _OnboardingSlideData data;
  final int pageIndex;
  final Size screenSize;

  const _SlidePage({
    required this.data,
    required this.pageIndex,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          TweenAnimationBuilder<double>(
            key: ValueKey('${data.title}-$pageIndex'),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, t, child) {
              return Transform.translate(
                offset: Offset(0, 22 * (1 - t)),
                child: Transform.scale(
                  scale: .82 + (.18 * t),
                  child: Opacity(
                    opacity: t.clamp(0, 1),
                    child: child,
                  ),
                ),
              );
            },
            child: _HeroIllustration(
              icon: data.icon,
              accent: data.accent,
              screenSize: screenSize,
            ),
          ),

          const SizedBox(height: 28),

          // Premium glass text panel
          TweenAnimationBuilder<double>(
            key: ValueKey('text-${data.title}'),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) {
              return Transform.translate(
                offset: Offset(0, 18 * (1 - t)),
                child: Opacity(
                  opacity: t.clamp(0, 1),
                  child: child,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.10),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.10),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: data.accent.withOpacity(.95),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenSize.width < 360 ? 24 : 28,
                      height: 1.14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.4,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.78),
                      fontSize: screenSize.width < 360 ? 13 : 14,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final Size screenSize;

  const _HeroIllustration({
    required this.icon,
    required this.accent,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final outer = screenSize.width < 360 ? 150.0 : 176.0;

    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: outer,
            height: outer,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withOpacity(.30),
                  accent.withOpacity(.12),
                  Colors.transparent,
                ],
                stops: const [0, .55, 1],
              ),
            ),
          ),

          Container(
            width: outer * .72,
            height: outer * .72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.10),
              border: Border.all(
                color: Colors.white.withOpacity(.24),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(.16),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          Container(
            width: outer * .50,
            height: outer * .50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.12),
              border: Border.all(
                color: Colors.white.withOpacity(.28),
              ),
            ),
            child: Icon(
              icon,
              size: outer * .24,
              color: Colors.white,
            ),
          ),

          Positioned(
            right: outer * .08,
            top: outer * .18,
            child: _SmallSpark(accent: accent),
          ),
          Positioned(
            left: outer * .05,
            bottom: outer * .20,
            child: _SmallSpark(accent: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SmallSpark extends StatelessWidget {
  final Color accent;

  const _SmallSpark({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: accent.withOpacity(.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(.45),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final int page;
  final int count;
  final bool isLast;
  final Color accent;
  final VoidCallback onNext;

  const _BottomPanel({
    required this.page,
    required this.count,
    required this.isLast,
    required this.accent,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(.17),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(
                count,
                    (i) {
                  final active = i == page;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(right: 7),
                    width: active ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withOpacity(.30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ),
          ),
          _NextButton(
            isLast: isLast,
            onTap: onNext,
            color: accent,
          ),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool isLast;
  final VoidCallback onTap;
  final Color color;

  const _NextButton({
    required this.isLast,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xff0A3D66),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: isLast ? 20 : 17,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: .92, end: 1).animate(animation),
                child: child,
              ),
            );
          },
          child: Row(
            key: ValueKey(isLast),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLast ? 'Get Started' : 'Next',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 7),
              Icon(
                isLast
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
