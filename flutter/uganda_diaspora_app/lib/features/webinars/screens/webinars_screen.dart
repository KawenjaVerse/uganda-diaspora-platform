import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class WebinarsScreen extends StatefulWidget {
  const WebinarsScreen({super.key});

  @override
  State<WebinarsScreen> createState() => _WebinarsScreenState();
}

class _WebinarsScreenState extends State<WebinarsScreen> {
  List<dynamic> _webinars = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient.instance.getWebinars();
      if (mounted) setState(() { _webinars = data['data'] ?? []; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Webinars')),
      body: _loading
          ? ListView.builder(padding: const EdgeInsets.all(16), itemCount: 5,
              itemBuilder: (_, __) => const Padding(padding: EdgeInsets.only(bottom: 16), child: ShimmerCard()))
          : RefreshIndicator(
              onRefresh: _load,
              child: _webinars.isEmpty
                  ? const Center(child: Text('No webinars available'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _webinars.length,
                      itemBuilder: (_, i) => _buildWebinarCard(_webinars[i]),
                    ),
            ),
    );
  }

  Widget _buildWebinarCard(Map webinar) {
    final isLive = webinar['isLive'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLive ? AppColors.ugandaRed.withOpacity(0.4) : Theme.of(context).dividerColor.withOpacity(0.5), width: isLive ? 1.5 : 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              NetworkImageWidget(imageUrl: webinar['thumbnailUrl'], height: 180, width: double.infinity, borderRadius: 0, fallbackIcon: Icons.play_circle_outline_rounded),
              if (isLive)
                Positioned(top: 12, left: 12, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.ugandaRed, borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.circle, color: Colors.white, size: 6),
                    SizedBox(width: 4),
                    Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ]),
                )),
              Positioned(bottom: 12, right: 12, child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
              )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(webinar['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                if (webinar['speakerName'] != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text(webinar['speakerName'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                  ]),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: webinar['youtubeUrl'] != null ? () => launchUrl(Uri.parse(webinar['youtubeUrl']), mode: LaunchMode.externalApplication) : null,
                      icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                      label: const Text('Watch'),
                    )),
                    const SizedBox(width: 12),
                    Text('${webinar['viewCount'] ?? 0} views', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
