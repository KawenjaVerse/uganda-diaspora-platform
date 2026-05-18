import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient.instance.getNotifications();
      if (mounted) setState(() { _notifications = data['data'] ?? []; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'news': return Icons.newspaper_rounded;
      case 'event': return Icons.event_rounded;
      case 'webinar': return Icons.video_call_rounded;
      case 'alert': return Icons.warning_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String? type) {
    switch (type) {
      case 'news': return AppColors.diasporaBlue;
      case 'event': return AppColors.nationalGreen;
      case 'webinar': return AppColors.webinarPurple;
      case 'alert': return AppColors.ugandaRed;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? ListView.builder(padding: const EdgeInsets.all(16), itemCount: 6,
              itemBuilder: (_, __) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ShimmerLoading(width: double.infinity, height: 72)))
          : RefreshIndicator(
              onRefresh: _load,
              child: _notifications.isEmpty
                  ? const Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textSecondaryLight),
                        SizedBox(height: 12),
                        Text('No notifications yet', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 16)),
                      ],
                    ))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (_, i) => _buildNotifCard(_notifications[i]),
                    ),
            ),
    );
  }

  Widget _buildNotifCard(Map notif) {
    final color = _typeColor(notif['type']);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(_typeIcon(notif['type']), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(notif['body'] ?? '', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
