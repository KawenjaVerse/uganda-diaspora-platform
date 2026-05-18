import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: _user?['avatarUrl'] != null ? NetworkImage(_user!['avatarUrl']) : null,
                        child: _user?['avatarUrl'] == null
                            ? Text(
                                (_user?['fullName'] ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.primary),
                              )
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_user?['fullName'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  Text(_user?['email'] ?? '', style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14)),
                  if (_user?['country'] != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondaryLight),
                        const SizedBox(width: 4),
                        Text(_user!['country'], style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (_user?['role'] ?? 'member').toString().toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildMenuSection([
                    (Icons.person_outline_rounded, 'Edit Profile', () {}),
                    (Icons.notifications_outlined, 'Notifications', () => context.go('/notifications')),
                    (Icons.work_outline_rounded, 'Opportunities', () => context.go('/opportunities')),
                    (Icons.event_outlined, 'Events', () => context.go('/events')),
                    (Icons.ondemand_video_rounded, 'Webinars', () => context.go('/webinars')),
                  ]),
                  const SizedBox(height: 16),
                  _buildMenuSection([
                    (Icons.help_outline_rounded, 'Help & Support', () {}),
                    (Icons.info_outline_rounded, 'About Uganda Diaspora', () {}),
                    (Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                      label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuSection(List<(IconData, String, VoidCallback)> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.$1, color: AppColors.primary, size: 22),
                title: Text(item.$2, style: const TextStyle(fontSize: 14)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondaryLight),
                onTap: item.$3,
                dense: true,
              ),
              if (i < items.length - 1)
                Divider(height: 1, indent: 56, color: Theme.of(context).dividerColor.withOpacity(0.4)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
