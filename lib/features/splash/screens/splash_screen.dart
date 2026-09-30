import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _roadController;
  late final AnimationController _loadingController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoSlide;

  late final Animation<double> _roadFade;
  late final Animation<Offset> _roadSlide;

  late final Animation<double> _loadingFade;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _roadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    );

    _logoScale = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutCubic,
      ),
    );

    _roadFade = CurvedAnimation(
      parent: _roadController,
      curve: Curves.easeOut,
    );

    _roadSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _roadController,
        curve: Curves.easeOutCubic,
      ),
    );

    _loadingFade = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeOut,
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(
      const Duration(milliseconds: 150),
    );

    if (!mounted) return;

    _logoController.forward();

    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (!mounted) return;

    _roadController.forward();

    await Future.delayed(
      const Duration(milliseconds: 350),
    );

    if (!mounted) return;

    _loadingController.forward();

    await Future.delayed(
      const Duration(milliseconds: 1500),
    );

    if (!mounted) return;

    widget.onFinished();
  }

  @override
  void dispose() {
    _timer?.cancel();

    _logoController.dispose();
    _roadController.dispose();
    _loadingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Very subtle blue background glow.
          Positioned(
            top: -180,
            left: -120,
            right: -120,
            child: IgnorePointer(
              child: Container(
                height: 420,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.0,
                    colors: [
                      const Color(0xFFEAF2FF).withOpacity(0.85),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom road and landscape.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _roadController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _roadFade,
                  child: SlideTransition(
                    position: _roadSlide,
                    child: child,
                  ),
                );
              },
              child: const _RoadBackground(),
            ),
          ),

          // Main content.
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                ),
                child: Column(
                  children: [
                    const Spacer(
                      flex: 4,
                    ),

                    // RentKaro logo.
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _logoFade,
                          child: SlideTransition(
                            position: _logoSlide,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: const _RentKaroLogo(),
                    ),

                    const SizedBox(height: 46),

                    // Loading animation.
                    FadeTransition(
                      opacity: _loadingFade,
                      child: const _AnimatedLoadingBar(),
                    ),

                    const Spacer(
                      flex: 5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RentKaroLogo extends StatelessWidget {
  const _RentKaroLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Minimal car roof.
        SizedBox(
          width: 285,
          height: 68,
          child: CustomPaint(
            painter: _CarRoofPainter(),
          ),
        ),

        const SizedBox(height: 4),

        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 52,
              fontWeight: FontWeight.w800,
              letterSpacing: -2.4,
              height: 0.95,
            ),
            children: [
              TextSpan(
                text: 'Rent',
                style: TextStyle(
                  color: Color(0xFF0B1F44),
                ),
              ),
              TextSpan(
                text: 'Kar',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.only(left: 1),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 43,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CarRoofPainter extends CustomPainter {
  const _CarRoofPainter();

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7;

    final gradient = const LinearGradient(
      colors: [
        Color(0xFF0B1F44),
        Color(0xFF2563EB),
      ],
    ).createShader(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
    );

    paint.shader = gradient;

    final path = Path();

    path.moveTo(
      12,
      size.height * 0.75,
    );

    path.cubicTo(
      size.width * 0.25,
      size.height * 0.70,
      size.width * 0.28,
      size.height * 0.10,
      size.width * 0.55,
      size.height * 0.10,
    );

    path.cubicTo(
      size.width * 0.72,
      size.height * 0.10,
      size.width * 0.84,
      size.height * 0.48,
      size.width - 12,
      size.height * 0.78,
    );

    canvas.drawPath(
      path,
      paint,
    );

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..color = const Color(0xFF2563EB).withOpacity(0.65);

    final innerPath = Path();

    innerPath.moveTo(
      size.width * 0.25,
      size.height * 0.66,
    );

    innerPath.cubicTo(
      size.width * 0.40,
      size.height * 0.45,
      size.width * 0.58,
      size.height * 0.35,
      size.width * 0.72,
      size.height * 0.60,
    );

    canvas.drawPath(
      innerPath,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}

class _AnimatedLoadingBar extends StatefulWidget {
  const _AnimatedLoadingBar();

  @override
  State<_AnimatedLoadingBar> createState() =>
      _AnimatedLoadingBarState();
}

class _AnimatedLoadingBarState
    extends State<_AnimatedLoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1300,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              color: const Color(0xFFE8EEF8),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor:
                  0.35 + (_controller.value * 0.35),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0B1F44),
                          Color(0xFF2563EB),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadBackground extends StatelessWidget {
  const _RoadBackground();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: CustomPaint(
          painter: _RoadPainter(),
        ),
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  const _RoadPainter();

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    // Soft blue hills.
    final hillPaint = Paint()
      ..color = const Color(0xFFEAF2FF);

    final hillPath = Path();

    hillPath.moveTo(
      0,
      size.height * 0.45,
    );

    hillPath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.10,
      size.width * 0.52,
      size.height * 0.48,
    );

    hillPath.quadraticBezierTo(
      size.width * 0.78,
      size.height * 0.80,
      size.width,
      size.height * 0.32,
    );

    hillPath.lineTo(
      size.width,
      size.height,
    );

    hillPath.lineTo(
      0,
      size.height,
    );

    hillPath.close();

    canvas.drawPath(
      hillPath,
      hillPaint,
    );

    // Road.
    final roadPaint = Paint()
      ..color = const Color(0xFFBFD7FF);

    final roadPath = Path();

    roadPath.moveTo(
      size.width * 0.38,
      size.height,
    );

    roadPath.cubicTo(
      size.width * 0.43,
      size.height * 0.78,
      size.width * 0.58,
      size.height * 0.68,
      size.width * 0.50,
      size.height * 0.54,
    );

    roadPath.cubicTo(
      size.width * 0.47,
      size.height * 0.47,
      size.width * 0.55,
      size.height * 0.41,
      size.width * 0.63,
      size.height * 0.34,
    );

    roadPath.lineTo(
      size.width * 0.78,
      size.height * 0.34,
    );

    roadPath.cubicTo(
      size.width * 0.65,
      size.height * 0.48,
      size.width * 0.63,
      size.height * 0.62,
      size.width * 0.70,
      size.height,
    );

    roadPath.close();

    canvas.drawPath(
      roadPath,
      roadPaint,
    );

    // Road lane.
    final lanePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final lanePath = Path();

    lanePath.moveTo(
      size.width * 0.53,
      size.height,
    );

    lanePath.cubicTo(
      size.width * 0.56,
      size.height * 0.78,
      size.width * 0.61,
      size.height * 0.67,
      size.width * 0.56,
      size.height * 0.55,
    );

    canvas.drawPath(
      lanePath,
      lanePaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}