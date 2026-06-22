import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.getMe();
      if (mounted) setState(() { _user = Map<String, dynamic>.from(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    if (mounted) context.go('/login');
  }

  String get _initials {
    final name = _user?['fullName'] ?? 'U';
    final parts = name.toString().trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'U';
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 400, maxHeight: 400);
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      setState(() { _user = Map<String, dynamic>.from(_user ?? {})..['avatarUrl'] = base64Str; });

      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('auth_user');
      if (userJson != null) {
        try {
          final userMap = Map<String, dynamic>.from(jsonDecode(userJson));
          userMap['avatarUrl'] = base64Str;
          await prefs.setString('auth_user', jsonEncode(userMap));
        } catch (_) {}
      }

      final userId = _user?['id'];
      if (userId != null) {
        try { await ApiClient.instance.updateUser(userId as int, {'avatarUrl': base64Str}); } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white, size: 16), SizedBox(width: 8), Text('Profile photo updated')]),
          backgroundColor: AppColors.primaryBlack,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not update photo')));
    }
  }

  Widget _buildAvatarContent() {
    final avatarUrl = _user?['avatarUrl'] as String?;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('data:')) {
        try {
          final idx = avatarUrl.indexOf(',');
          if (idx != -1) {
            final bytes = base64Decode(avatarUrl.substring(idx + 1));
            return ClipOval(child: Image.memory(bytes, width: 96, height: 96, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildInitialsAvatar()));
          }
        } catch (_) {}
      } else {
        return ClipOval(child: Image.network(avatarUrl, width: 96, height: 96, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildInitialsAvatar()));
      }
    }
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() => Center(
    child: Text(_initials, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
  );

  String _memberSince() {
    final created = _user?['createdAt'];
    if (created == null) return 'Member';
    try {
      final dt = DateTime.parse(created.toString());
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (_) { return 'Member'; }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 8),
            Text('Delete Account', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ],
        ),
        content: const Text(
          'This will permanently delete your account and all your data. This action cannot be undone.\n\nAre you absolutely sure?',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete My Account', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    final userId = _user?['id'];
    if (userId == null) return;

    setState(() => _deleting = true);
    try {
      await ApiClient.instance.deleteUser(userId as int);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_user');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Color(0xFFDC2626),
        ));
        context.go('/login');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Could not delete account. Please try again.'),
          backgroundColor: AppColors.primaryBlack,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primaryBlack,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                onPressed: () => _showEditSheet(context),
                tooltip: 'Edit Profile',
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF121212), Color(0xFF1C0800)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background accent circle
                    Positioned(
                      right: -50, top: -50,
                      child: Container(
                        width: 200, height: 200,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkOrange.withOpacity(0.07)),
                      ),
                    ),
                    Positioned(
                      left: -40, bottom: -40,
                      child: Container(
                        width: 160, height: 160,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkOrange.withOpacity(0.04)),
                      ),
                    ),
                    // Content — fully centered
                    Center(
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
                            // Avatar — tappable
                            GestureDetector(
                              onTap: _pickAvatar,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 96, height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [AppColors.darkOrange, Color(0xFFB45309)],
                                      ),
                                      boxShadow: [BoxShadow(color: AppColors.darkOrange.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
                                    ),
                                    child: _buildAvatarContent(),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlack,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white12, width: 1),
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _user?['fullName'] ?? 'User',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _user?['email'] ?? '',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.darkOrange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.darkOrange.withOpacity(0.4)),
                              ),
                              child: Text(
                                (_user?['role'] ?? 'member').toString().toUpperCase(),
                                style: const TextStyle(color: AppColors.darkOrange, fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats Row ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        _StatItem(label: 'Member Since', value: _memberSince()),
                        _Divider(),
                        _StatItem(label: 'Country', value: _user?['country'] ?? '—'),
                        _Divider(),
                        _StatItem(label: 'Role', value: (_user?['role'] ?? 'member').toString().capitalize()),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Quick Access ──────────────────────────────────────
                  _SectionHeader('Quick Access'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _QuickTile(
                        icon: Icons.miscellaneous_services_rounded,
                        label: 'Our Services',
                        color: AppColors.darkOrange,
                        onTap: () => context.push('/services'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickTile(
                        icon: Icons.contact_support_rounded,
                        label: 'Contact Us',
                        color: AppColors.deepRed,
                        onTap: () => context.push('/contact'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickTile(
                        icon: Icons.how_to_reg_rounded,
                        label: 'Register',
                        color: const Color(0xFF2563EB),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Use the Register button on the Home screen')),
                        ),
                      )),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Explore ───────────────────────────────────────────
                  _SectionHeader('Explore'),
                  const SizedBox(height: 8),
                  _MenuSection([
                    _MenuItem(Icons.notifications_outlined, 'Notifications', () => context.go('/notifications')),
                    _MenuItem(Icons.event_outlined, 'Events', () => context.go('/events')),
                    _MenuItem(Icons.ondemand_video_rounded, 'Webinars', () => context.go('/webinars')),
                  ]),

                  const SizedBox(height: 16),

                  // ── Support ───────────────────────────────────────────
                  _SectionHeader('Support'),
                  const SizedBox(height: 8),
                  _MenuSection([
                    _MenuItem(Icons.help_outline_rounded, 'Help & Support', () => context.push('/contact')),
                    _MenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', () => context.push('/privacy-policy')),
                  ]),

                  const SizedBox(height: 20),

                  // ── Sign Out ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                      label: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Delete Account ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _deleting ? null : _confirmDeleteAccount,
                      icon: _deleting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC2626)))
                          : const Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626), size: 18),
                      label: Text(
                        _deleting ? 'Deleting…' : 'Delete Account',
                        style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0x44DC2626)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    final nameCtrl = TextEditingController(text: _user?['fullName'] ?? '');
    final countryCtrl = TextEditingController(text: _user?['country'] ?? '');
    final professionCtrl = TextEditingController(text: _user?['profession'] ?? '');
    final bioCtrl = TextEditingController(text: _user?['bio'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryBlack)),
              const SizedBox(height: 20),
              _EditField(ctrl: nameCtrl, label: 'Full Name', icon: Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _EditField(ctrl: countryCtrl, label: 'Country', icon: Icons.public_rounded),
              const SizedBox(height: 12),
              _EditField(ctrl: professionCtrl, label: 'Profession', icon: Icons.work_outline_rounded),
              const SizedBox(height: 12),
              _EditField(ctrl: bioCtrl, label: 'Bio', icon: Icons.edit_note_rounded, maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      if (_user != null) {
                        _user!['fullName'] = nameCtrl.text;
                        _user!['country'] = countryCtrl.text;
                        _user!['profession'] = professionCtrl.text;
                        _user!['bio'] = bioCtrl.text;
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated'), backgroundColor: AppColors.primaryBlack),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondaryLight, letterSpacing: 0.5));
}

class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryBlack),
          textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 32, color: Colors.grey.shade100);
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryBlack),
              textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.onTap);
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection(this.items);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(color: AppColors.primaryBlack.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
                  child: Icon(item.icon, color: AppColors.primaryBlack, size: 16),
                ),
                title: Text(item.label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondaryLight),
                onTap: item.onTap,
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              ),
              if (i < items.length - 1)
                Divider(height: 1, indent: 56, endIndent: 14, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final int maxLines;
  const _EditField({required this.ctrl, required this.label, required this.icon, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlack)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondaryLight),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryBlack, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

extension _StringExt on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
