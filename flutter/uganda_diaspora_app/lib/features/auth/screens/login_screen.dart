import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.instance.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['token']);
      await prefs.setString('auth_user', jsonEncode(response['user']));
      if (mounted) context.go('/');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Invalid email or password', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            backgroundColor: AppColors.ugandaRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: LoadingOverlay(
        isLoading: _isLoading,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              // ── Top: dark header with coat of arms ──────────────────────
              SizedBox(
                height: size.height * 0.40,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Coat of arms from assets
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ugandaYellow.withOpacity(0.25),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/coat_of_arms.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _FallbackCrest(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'REPUBLIC OF UGANDA',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Diaspora Portal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Uganda flag thin strip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _FlagDot(color: Colors.black, border: true),
                          const SizedBox(width: 4),
                          _FlagDot(color: AppColors.ugandaYellow),
                          const SizedBox(width: 4),
                          _FlagDot(color: AppColors.ugandaRed),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom: white card with form ─────────────────────────────
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome heading
                            const Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign in to your Diaspora account',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // ── Form ───────────────────────────────────────
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Email field
                                  _LoginField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    hint: 'you@example.com',
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Email is required';
                                      if (!v.contains('@')) return 'Enter a valid email address';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Password field
                                  _LoginField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    hint: 'Enter your password',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Password is required';
                                      if (v.length < 6) return 'At least 6 characters required';
                                      return null;
                                    },
                                  ),

                                  // Forgot password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => context.push('/forgot-password'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.ugandaYellow,
                                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                      ),
                                      child: const Text(
                                        'Forgot password?',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Sign in button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                      ),
                                      child: const Text('Sign In'),
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: Colors.grey.shade200)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        child: Text(
                                          'New to Uganda Diaspora?',
                                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: Colors.grey.shade200)),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Create account button (outlined)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: OutlinedButton(
                                      onPressed: () => context.push('/register'),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.black, width: 1.5),
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      ),
                                      child: const Text('Create an Account'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable login field ───────────────────────────────────────────────────
class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _LoginField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, size: 19, color: Colors.grey.shade500),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.ugandaRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.ugandaRed, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ── Flag colour dot ────────────────────────────────────────────────────────
class _FlagDot extends StatelessWidget {
  final Color color;
  final bool border;
  const _FlagDot({required this.color, this.border = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border ? Border.all(color: Colors.white30, width: 1) : null,
      ),
    );
  }
}

// ── Fallback coat of arms (if asset not found) ─────────────────────────────
class _FallbackCrest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CrestPainter());
  }
}

class _CrestPainter extends CustomPainter {
  static const _stripeColors = [
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
      canvas.drawRect(Rect.fromLTWH(0, i * sh, w, sh + 1), Paint()..color = _stripeColors[i]);
    }

    // White circle
    final c = Offset(w / 2, h / 2);
    canvas.drawCircle(c, w * 0.30, Paint()..color = Colors.white);
    canvas.drawCircle(c, w * 0.30, Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Crane
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

    final lp = Paint()..color = const Color(0xFF4A4A4A)..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx - r * 0.1, c.dy + r * 0.3), Offset(c.dx - r * 0.15, c.dy + r * 0.55), lp);
    canvas.drawLine(Offset(c.dx + r * 0.1, c.dy + r * 0.3), Offset(c.dx + r * 0.15, c.dy + r * 0.55), lp);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
