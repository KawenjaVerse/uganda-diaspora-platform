import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _pulseCtrl;

  // Background image fade
  late final Animation<double> _bgOpacity;

  // Logo scale + opacity
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // Glow ring pulse
  late final Animation<double> _glowScale;

  // Text fade + slide
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  // Loading dots
  late final Animation<double> _dotsOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _mainCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);

    _bgOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.45, curve: Curves.easeOut)),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.28, 0.68, curve: Curves.elasticOut)),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.28, 0.52)),
    );

    _glowScale = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.60, 0.85)),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.60, 0.85, curve: Curves.easeOut)),
    );

    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.80, 1.0)),
    );

    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 250));
    _mainCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 3600));
    if (mounted) _navigate();
  }

  Future<void> _navigate() async {
    // Navigate to home — auth is optional, public users go directly to home
    if (!mounted) return;
    context.go('/');
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainCtrl, _pulseCtrl]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Full-screen background image ─────────────────────────────
              Opacity(
                opacity: _bgOpacity.value,
                child: Image.asset(
                  'assets/images/splash_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF121212), Color(0xFF1C0A00), Color(0xFF0A0000)],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Dark overlay 65% ──────────────────────────────────────────
              Container(color: Colors.black.withOpacity(0.65)),

              // ── Subtle diagonal pattern overlay ───────────────────────────
              CustomPaint(painter: _PatternPainter(), size: size),

              // ── Main content ─────────────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Glow ring + logo
                    Transform.scale(
                      scale: _glowScale.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.darkOrange.withOpacity(0.25),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              // Orange ring
                              Container(
                                width: 132,
                                height: 132,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.darkOrange.withOpacity(0.7),
                                    width: 2,
                                  ),
                                ),
                              ),
                              // White circle with coat of arms
                              Container(
                                width: 118,
                                height: 118,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x40D97706),
                                      blurRadius: 32,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(
                                  'assets/images/coat_of_arms.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => CustomPaint(
                                    painter: _CoatOfArmsPainter(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 44),

                    // ── App name + tagline ────────────────────────────────
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          children: [
                            // "UGANDA" in white
                            const Text(
                              'UGANDA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 10,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Orange accent line under UGANDA
                            Container(
                              width: 200,
                              height: 2,
                              decoration: const BoxDecoration(
                                gradient: AppColors.orangeGradient,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // "DIASPORA" in orange
                            const Text(
                              'DIASPORA',
                              style: TextStyle(
                                color: AppColors.darkOrange,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 8,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Tagline
                            const Text(
                              'Connecting Ugandans Worldwide',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ── Loading dots ──────────────────────────────────────
                    FadeTransition(
                      opacity: _dotsOpacity,
                      child: _LoadingDots(ctrl: _pulseCtrl),
                    ),

                    const SizedBox(height: 20),

                    // ── Uganda flag strip at very bottom ──────────────────
                    Row(
                      children: [
                        AppColors.ugandaBlack,
                        AppColors.ugandaYellow,
                        AppColors.ugandaRed,
                        AppColors.ugandaBlack,
                        AppColors.ugandaYellow,
                        AppColors.ugandaRed,
                      ].map((c) => Expanded(child: Container(height: 5, color: c))).toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Loading dots ───────────────────────────────────────────────────────────
class _LoadingDots extends StatelessWidget {
  final AnimationController ctrl;
  const _LoadingDots({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase = (ctrl.value + i * 0.3) % 1.0;
            final scale = 0.6 + sin(phase * pi) * 0.5;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 7 * scale,
              height: 7 * scale,
              decoration: BoxDecoration(
                color: [Colors.white, AppColors.darkOrange, AppColors.deepRed][i]
                    .withOpacity(0.5 + scale * 0.5),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Subtle diagonal pattern overlay ───────────────────────────────────────
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;
    const spacing = 40.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Fallback coat of arms painter ─────────────────────────────────────────
class _CoatOfArmsPainter extends CustomPainter {
  static const _colors = [
    Colors.black,
    AppColors.ugandaYellow,
    AppColors.ugandaRed,
    Colors.black,
    AppColors.ugandaYellow,
    AppColors.ugandaRed,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sh = h / 6;

    for (int i = 0; i < 6; i++) {
      canvas.drawRect(Rect.fromLTWH(0, i * sh, w, sh + 1), Paint()..color = _colors[i]);
    }

    final c = Offset(w / 2, h / 2);
    canvas.drawCircle(c, w * 0.30, Paint()..color = Colors.white);
    canvas.drawCircle(c, w * 0.30, Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    _drawCrane(canvas, c, w * 0.22);
  }

  void _drawCrane(Canvas canvas, Offset c, double r) {
    final p = Paint()..color = const Color(0xFF4A4A4A);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.1), width: r * 0.9, height: r * 0.5), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx - r * 0.05, c.dy - r * 0.78), width: r * 0.22, height: r * 0.18), p);
    canvas.drawCircle(Offset(c.dx - r * 0.05, c.dy - r * 0.9), r * 0.08, Paint()..color = AppColors.ugandaRed);
    final neck = Path()
      ..moveTo(c.dx - r * 0.05, c.dy - r * 0.05)
      ..quadraticBezierTo(c.dx - r * 0.15, c.dy - r * 0.5, c.dx - r * 0.1, c.dy - r * 0.7)
      ..lineTo(c.dx + r * 0.05, c.dy - r * 0.65)
      ..quadraticBezierTo(c.dx + r * 0.05, c.dy - r * 0.4, c.dx + r * 0.05, c.dy - r * 0.05)
      ..close();
    canvas.drawPath(neck, p);
    final lw = Path()
      ..moveTo(c.dx - r * 0.4, c.dy)
      ..quadraticBezierTo(c.dx - r * 0.85, c.dy - r * 0.35, c.dx - r * 0.8, c.dy - r * 0.1)
      ..quadraticBezierTo(c.dx - r * 0.5, c.dy + r * 0.05, c.dx - r * 0.2, c.dy + r * 0.1)
      ..close();
    canvas.drawPath(lw, p);
    final rw = Path()
      ..moveTo(c.dx + r * 0.3, c.dy)
      ..quadraticBezierTo(c.dx + r * 0.75, c.dy - r * 0.35, c.dx + r * 0.7, c.dy - r * 0.1)
      ..quadraticBezierTo(c.dx + r * 0.4, c.dy + r * 0.05, c.dx + r * 0.1, c.dy + r * 0.1)
      ..close();
    canvas.drawPath(rw, p);
    final lp = Paint()..color = const Color(0xFF4A4A4A)..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx - r * 0.1, c.dy + r * 0.3), Offset(c.dx - r * 0.15, c.dy + r * 0.55), lp);
    canvas.drawLine(Offset(c.dx + r * 0.1, c.dy + r * 0.3), Offset(c.dx + r * 0.15, c.dy + r * 0.55), lp);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
