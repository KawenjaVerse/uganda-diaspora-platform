import 'dart:math';
import 'package:flutter/material.dart';
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
  late final AnimationController _waveCtrl;

  late final List<Animation<double>> _stripeAnims;
  late final Animation<double> _circleScale;
  late final Animation<double> _circleOpacity;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineOpacity;

  static const List<Color> _stripeColors = [
    Colors.black,
    AppColors.ugandaYellow,
    AppColors.ugandaRed,
    Colors.black,
    AppColors.ugandaYellow,
    AppColors.ugandaRed,
  ];

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();

    _stripeAnims = List.generate(6, (i) {
      final start = i * 0.065;
      final end = (start + 0.28).clamp(0.0, 1.0);
      return Tween<double>(begin: -1.0, end: 0.0).animate(
        CurvedAnimation(parent: _mainCtrl, curve: Interval(start, end, curve: Curves.easeOutCubic)),
      );
    });

    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.42, 0.68, curve: Curves.elasticOut)),
    );
    _circleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.42, 0.55)),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.58, 0.75)),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.55, 0.72, curve: Curves.easeOutBack)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.70, 0.88)),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.70, 0.88, curve: Curves.easeOutCubic)),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.80, 1.0)),
    );

    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 350));
    _mainCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 3800));
    if (mounted) _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (!mounted) return;
    context.go(token != null && token.isNotEmpty ? '/' : '/login');
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final stripeH = size.height / 6;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainCtrl, _waveCtrl]),
        builder: (context, _) {
          final wave = sin(_waveCtrl.value * 2 * pi);
          return Stack(
            children: [
              // ── Animated flag stripes (full-screen) ──────────────────
              ...List.generate(6, (i) {
                // Slight vertical wave on each stripe after reveal
                final revealed = _stripeAnims[i].value >= -0.02;
                final waveShift = revealed ? sin(_waveCtrl.value * 2 * pi + i * 0.6) * 6.0 : 0.0;
                return Positioned(
                  top: i * stripeH + waveShift,
                  left: 0,
                  right: 0,
                  height: stripeH + 2,
                  child: Transform.translate(
                    offset: Offset(_stripeAnims[i].value * size.width, 0),
                    child: Container(
                      color: _stripeColors[i],
                      child: _stripeColors[i] == AppColors.ugandaYellow
                          ? Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.ugandaYellow, AppColors.ugandaYellow.withOpacity(0.75), AppColors.ugandaYellow],
                                  stops: const [0, 0.5, 1],
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              }),

              // ── Semi-dark overlay for contrast ───────────────────────
              Container(color: Colors.black.withOpacity(0.45)),

              // ── Centre: coat of arms circle ──────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Outer glow ring
                    Transform.scale(
                      scale: _circleScale.value,
                      child: Opacity(
                        opacity: _circleOpacity.value,
                        child: Container(
                          width: 148,
                          height: 148,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.ugandaYellow.withOpacity(0.6 + wave * 0.2),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.ugandaYellow.withOpacity(0.35 + wave * 0.1),
                                blurRadius: 30 + wave * 8,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: AppColors.ugandaRed.withOpacity(0.2),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Opacity(
                                opacity: _logoOpacity.value,
                                child: _CoatOfArmsWidget(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 44),

                    // ── App name ───────────────────────────────────────
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          children: [
                            // "UGANDA" in bold white
                            const Text(
                              'UGANDA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8,
                                height: 1,
                              ),
                            ),
                            // Yellow underline divider
                            Container(
                              width: 180,
                              height: 3,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Colors.transparent,
                                  AppColors.ugandaYellow,
                                  Colors.transparent,
                                ]),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // "DIASPORA" in yellow
                            const Text(
                              'DIASPORA',
                              style: TextStyle(
                                color: AppColors.ugandaYellow,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Tagline
                            FadeTransition(
                              opacity: _taglineOpacity,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Connecting Ugandans Worldwide',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom flag strip ─────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Loading dots
                    FadeTransition(
                      opacity: _taglineOpacity,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final dotWave = sin(_waveCtrl.value * 2 * pi + i * 1.0);
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 6,
                              height: 6 + dotWave * 2,
                              decoration: BoxDecoration(
                                color: [Colors.white, AppColors.ugandaYellow, AppColors.ugandaRed][i].withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    // Flag stripe bar
                    Row(
                      children: _stripeColors.map((c) => Expanded(
                        child: Container(height: 10, color: c),
                      )).toList(),
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

// ── Coat of Arms Widget ──────────────────────────────────────────────────────
class _CoatOfArmsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CustomPaint(
        painter: _CoatOfArmsPainter(),
        child: const SizedBox(width: 130, height: 130),
      ),
    );
  }
}

class _CoatOfArmsPainter extends CustomPainter {
  static const List<Color> _stripeColors = [
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
    final stripeH = h / 6;

    // Draw Uganda flag stripes
    for (int i = 0; i < 6; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeH, w, stripeH + 1),
        Paint()..color = _stripeColors[i],
      );
    }

    // White circle in center
    final center = Offset(w / 2, h / 2);
    canvas.drawCircle(center, w * 0.30, Paint()..color = Colors.white);

    // Grey border on the circle
    canvas.drawCircle(center, w * 0.30, Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Crane body (simplified silhouette)
    _drawCrane(canvas, center, w * 0.22);
  }

  void _drawCrane(Canvas canvas, Offset center, double r) {
    final paint = Paint()..color = const Color(0xFF4A4A4A)..style = PaintingStyle.fill;

    // Body ellipse
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.1), width: r * 0.9, height: r * 0.5),
      paint,
    );

    // Neck
    final neckPath = Path()
      ..moveTo(center.dx - r * 0.05, center.dy - r * 0.05)
      ..quadraticBezierTo(center.dx - r * 0.15, center.dy - r * 0.5, center.dx - r * 0.1, center.dy - r * 0.7)
      ..lineTo(center.dx + r * 0.05, center.dy - r * 0.65)
      ..quadraticBezierTo(center.dx + r * 0.05, center.dy - r * 0.4, center.dx + r * 0.05, center.dy - r * 0.05)
      ..close();
    canvas.drawPath(neckPath, paint);

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - r * 0.05, center.dy - r * 0.78), width: r * 0.22, height: r * 0.18),
      paint,
    );

    // Red crown on head
    final crownPaint = Paint()..color = AppColors.ugandaRed;
    canvas.drawCircle(Offset(center.dx - r * 0.05, center.dy - r * 0.9), r * 0.08, crownPaint);

    // Left wing
    final leftWing = Path()
      ..moveTo(center.dx - r * 0.4, center.dy)
      ..quadraticBezierTo(center.dx - r * 0.85, center.dy - r * 0.35, center.dx - r * 0.8, center.dy - r * 0.1)
      ..quadraticBezierTo(center.dx - r * 0.5, center.dy + r * 0.05, center.dx - r * 0.2, center.dy + r * 0.1)
      ..close();
    canvas.drawPath(leftWing, paint);

    // Right wing
    final rightWing = Path()
      ..moveTo(center.dx + r * 0.3, center.dy)
      ..quadraticBezierTo(center.dx + r * 0.75, center.dy - r * 0.35, center.dx + r * 0.7, center.dy - r * 0.1)
      ..quadraticBezierTo(center.dx + r * 0.4, center.dy + r * 0.05, center.dx + r * 0.1, center.dy + r * 0.1)
      ..close();
    canvas.drawPath(rightWing, paint);

    // Legs
    final legPaint = Paint()..color = const Color(0xFF4A4A4A)..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(center.dx - r * 0.1, center.dy + r * 0.3), Offset(center.dx - r * 0.15, center.dy + r * 0.55), legPaint);
    canvas.drawLine(Offset(center.dx + r * 0.1, center.dy + r * 0.3), Offset(center.dx + r * 0.15, center.dy + r * 0.55), legPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
