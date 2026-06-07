import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: AppColors.primaryBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: AppColors.primaryBlack,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 18, right: 20),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Contact Us', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
                  SizedBox(height: 2),
                  Text('Ministry of Foreign Affairs, Uganda', style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w400)),
                ],
              ),
              background: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF121212), Color(0xFF1A0800)],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -40, top: -40,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkOrange.withOpacity(0.1)),
                    ),
                  ),
                  Positioned(
                    left: 20, bottom: 40,
                    child: Icon(Icons.contact_support_rounded, size: 80, color: Colors.white.withOpacity(0.04)),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Get In Touch'),
                  const SizedBox(height: 12),

                  _ContactCard(
                    icon: Icons.phone_rounded,
                    color: const Color(0xFF16A34A),
                    label: 'Phone',
                    value: '+256 414 259 679',
                    subtitle: 'Mon–Fri, 8:00 AM – 5:00 PM EAT',
                    onTap: () => _copy(context, '+256414259679', 'Phone number'),
                    actionLabel: 'Copy Number',
                  ),

                  const SizedBox(height: 12),

                  _ContactCard(
                    icon: Icons.email_rounded,
                    color: AppColors.darkOrange,
                    label: 'Email',
                    value: 'diaspora@mfa.go.ug',
                    subtitle: 'We respond within 48 hours',
                    onTap: () => _copy(context, 'diaspora@mfa.go.ug', 'Email address'),
                    actionLabel: 'Copy Email',
                  ),

                  const SizedBox(height: 24),
                  _SectionLabel('Follow Us'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _SocialCard(
                          icon: Icons.close,
                          customWidget: const Text('𝕏', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                          color: const Color(0xFF121212),
                          label: 'X (Twitter)',
                          handle: '@MFAUganda',
                          onTap: () => _copy(context, '@MFAUganda', 'X handle'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialCard(
                          icon: Icons.play_circle_filled_rounded,
                          color: const Color(0xFFDC2626),
                          label: 'YouTube',
                          handle: '@UgandaMFA',
                          onTap: () => _copy(context, 'youtube.com/@UgandaMFA', 'YouTube link'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _SectionLabel('Our Office'),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.deepRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.location_on_rounded, color: AppColors.deepRed, size: 22),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Headquarters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primaryBlack)),
                                  SizedBox(height: 4),
                                  Text('Ministry of Foreign Affairs\nPlot 3, Yusuf Lule Road\nKampala, Uganda', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight, height: 1.6)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondaryLight),
                            const SizedBox(width: 8),
                            const Text('Office Hours', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF16A34A).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: const Text('Open Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _OfficeHoursRow('Monday – Friday', '8:00 AM – 5:00 PM'),
                        _OfficeHoursRow('Saturday', '9:00 AM – 1:00 PM'),
                        _OfficeHoursRow('Sunday & Public Holidays', 'Closed'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _SectionLabel('Send a Message'),
                  const SizedBox(height: 12),
                  const _ContactForm(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryBlack, letterSpacing: 0.2));
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value, subtitle, actionLabel;
  final VoidCallback onTap;
  const _ContactCard({required this.icon, required this.color, required this.label, required this.value, required this.subtitle, required this.onTap, required this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryBlack)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: Text(actionLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialCard extends StatelessWidget {
  final IconData icon;
  final Widget? customWidget;
  final Color color;
  final String label, handle;
  final VoidCallback onTap;
  const _SocialCard({required this.icon, this.customWidget, required this.color, required this.label, required this.handle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customWidget ?? Icon(icon, color: Colors.white, size: 28),
              if (customWidget == null) const SizedBox(height: 4),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(handle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficeHoursRow extends StatelessWidget {
  final String day, hours;
  const _OfficeHoursRow(this.day, this.hours);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
          Text(hours, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlack)),
        ],
      ),
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm();

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _sent = false;
  bool _sending = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _msgCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() { _sent = true; _sending = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF16A34A).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 36),
            ),
            const SizedBox(height: 12),
            const Text('Message Sent!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('We\'ll get back to you within 48 hours.', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _FormField(controller: _nameCtrl, label: 'Your Name', hint: 'e.g. John Doe', icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          _FormField(controller: _emailCtrl, label: 'Email Address', hint: 'your@email.com', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Message', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlack)),
              const SizedBox(height: 6),
              TextField(
                controller: _msgCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'How can we help you?',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMutedLight),
                  filled: true,
                  fillColor: AppColors.inputBackgroundLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sending ? null : _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlack,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              child: _sending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Send Message'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType? keyboard;
  const _FormField({required this.controller, required this.label, required this.hint, required this.icon, this.keyboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlack)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMutedLight),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondaryLight),
            filled: true,
            fillColor: AppColors.inputBackgroundLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
