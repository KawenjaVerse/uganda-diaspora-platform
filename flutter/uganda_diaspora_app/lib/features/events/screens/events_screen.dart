import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<dynamic> _events = [];
  bool _loading = true;
  bool _upcomingOnly = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient.instance.getEvents(upcoming: _upcomingOnly ? true : null);
      if (mounted) setState(() { _events = data['data'] ?? []; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                const Text('Upcoming only', style: TextStyle(fontSize: 12)),
                Switch(
                  value: _upcomingOnly,
                  onChanged: (v) { setState(() => _upcomingOnly = v); _load(); },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? ListView.builder(padding: const EdgeInsets.all(16), itemCount: 4,
              itemBuilder: (_, __) => const Padding(padding: EdgeInsets.only(bottom: 16), child: ShimmerCard()))
          : RefreshIndicator(
              onRefresh: _load,
              child: _events.isEmpty
                  ? const Center(child: Text('No events found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _events.length,
                      itemBuilder: (_, i) => _buildEventCard(_events[i]),
                    ),
            ),
    );
  }

  Widget _buildEventCard(Map event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetworkImageWidget(imageUrl: event['imageUrl'], height: 160, width: double.infinity, borderRadius: 0, fallbackIcon: Icons.event_rounded),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (event['isVirtual'] == true) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: const Text('Virtual', style: TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w600)),
                    ),
                    if (event['category'] != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(event['category'], style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(event['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                if (event['description'] != null) ...[
                  const SizedBox(height: 6),
                  Text(event['description'], maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ],
                const SizedBox(height: 12),
                if (event['location'] != null)
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text(event['location'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                  ]),
                const SizedBox(height: 12),
                if (event['registrationUrl'] != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => launchUrl(Uri.parse(event['registrationUrl']), mode: LaunchMode.externalApplication),
                      child: const Text('Register'),
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
