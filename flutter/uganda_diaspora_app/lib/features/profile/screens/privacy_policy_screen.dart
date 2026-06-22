import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: Colors.white,
        title: const Text('Privacy Policy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, decoration: const BoxDecoration(gradient: AppColors.orangeGradient)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _PolicyHeader(
            title: 'Uganda Diaspora Platform',
            subtitle: 'Privacy Policy',
            effective: 'Effective Date: 1 January 2025',
          ),
          SizedBox(height: 24),
          _PolicySection(
            title: '1. Introduction',
            body: 'Welcome to the Uganda Diaspora Platform ("Platform", "we", "our", or "us"). We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and related services.\n\nPlease read this policy carefully. If you disagree with its terms, please discontinue use of the Platform.',
          ),
          _PolicySection(
            title: '2. Information We Collect',
            body: 'We collect information that you provide directly to us, including:\n\n• Full name, email address, and password when you create an account\n• Country of residence and profession\n• Profile photo and biography\n• Community posts, comments, and interactions\n• Diaspora registration details (date of birth, gender, national ID, contact information)\n\nWe also collect certain information automatically when you use the Platform, such as device identifiers, usage data, and log information.',
          ),
          _PolicySection(
            title: '3. How We Use Your Information',
            body: 'We use the information we collect to:\n\n• Provide, operate, and maintain the Platform\n• Create and manage your account\n• Enable community features such as posts and comments\n• Send you notifications and updates relevant to the Ugandan diaspora\n• Respond to your inquiries and provide support\n• Improve and personalise your experience\n• Comply with legal obligations\n\nWe do not sell, trade, or rent your personal information to third parties.',
          ),
          _PolicySection(
            title: '4. Information Sharing',
            body: 'We may share your information in the following circumstances:\n\n• With your consent\n• To comply with applicable laws, regulations, or legal processes\n• To protect the rights, property, and safety of the Platform, our users, or the public\n• In connection with a merger, acquisition, or sale of all or a portion of our assets\n\nPublic information such as your display name and community posts may be visible to other users of the Platform.',
          ),
          _PolicySection(
            title: '5. Data Security',
            body: 'We implement appropriate technical and organisational measures to protect your personal information against unauthorised access, alteration, disclosure, or destruction. However, no method of transmission over the internet or electronic storage is 100% secure.\n\nYour account is protected by a password. You are responsible for maintaining the confidentiality of your password and for all activities under your account.',
          ),
          _PolicySection(
            title: '6. Data Retention',
            body: 'We retain your personal information for as long as your account is active or as needed to provide services. If you delete your account, we will delete or anonymise your personal data within 30 days, except where we are required to retain it for legal purposes.',
          ),
          _PolicySection(
            title: '7. Your Rights',
            body: 'Depending on your location, you may have the following rights:\n\n• Access — request a copy of the personal data we hold about you\n• Correction — request correction of inaccurate or incomplete data\n• Deletion — request deletion of your personal data (you may also delete your account directly within the app)\n• Portability — request a machine-readable copy of your data\n• Objection — object to certain types of processing\n\nTo exercise any of these rights, please contact us at privacy@ugandadiaspora.go.ug.',
          ),
          _PolicySection(
            title: '8. Children\'s Privacy',
            body: 'The Platform is not intended for use by individuals under the age of 18. We do not knowingly collect personal information from children under 18. If you become aware that a child has provided us with personal information, please contact us immediately.',
          ),
          _PolicySection(
            title: '9. Third-Party Services',
            body: 'The Platform may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to review the privacy policies of any third-party services you access through our Platform.',
          ),
          _PolicySection(
            title: '10. Changes to This Policy',
            body: 'We may update this Privacy Policy from time to time. We will notify you of any significant changes by posting a notice within the app or by sending you an email. Your continued use of the Platform after the effective date of the revised policy constitutes your acceptance of the changes.',
          ),
          _PolicySection(
            title: '11. Contact Us',
            body: 'If you have questions or concerns about this Privacy Policy or our data practices, please contact us:\n\nUganda Diaspora Platform\nMinistry of Foreign Affairs\nKampala, Uganda\nEmail: privacy@ugandadiaspora.go.ug\nPhone: +256 414 345 661',
          ),
          SizedBox(height: 32),
          _PolicyFooter(),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Components ────────────────────────────────────────────────────────────────

class _PolicyHeader extends StatelessWidget {
  final String title, subtitle, effective;
  const _PolicyHeader({required this.title, required this.subtitle, required this.effective});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF121212), Color(0xFF1C0800)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.darkOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.privacy_tip_outlined, color: AppColors.darkOrange, size: 24),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white54)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: AppColors.darkOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(effective, style: const TextStyle(fontSize: 11, color: AppColors.darkOrange, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title, body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryBlack)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Text(body, style: const TextStyle(fontSize: 13.5, height: 1.65, color: Color(0xFF374151))),
          ),
        ],
      ),
    );
  }
}

class _PolicyFooter extends StatelessWidget {
  const _PolicyFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkOrange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkOrange.withOpacity(0.15)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.darkOrange, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'By using the Uganda Diaspora Platform, you agree to this Privacy Policy.',
              style: TextStyle(fontSize: 12.5, color: AppColors.darkOrange, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
