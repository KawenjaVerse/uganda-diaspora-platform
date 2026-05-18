import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  List<dynamic> _opps = [];
  bool _loading = true;
  String? _type;

  final _types = ['job', 'scholarship', 'business', 'training', 'volunteer'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient.instance.getOpportunities(type: _type);
      if (mounted) setState(() { _opps = data['data'] ?? []; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _typeColor(String? type) {
    switch (type) {
      case 'scholarship': return AppColors.webinarPurple;
      case 'business': return AppColors.nationalGreen;
      case 'training': return AppColors.info;
      case 'volunteer': return AppColors.tourismOrange;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opportunities')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                _buildChip('All', null),
                ..._types.map((t) => _buildChip(t[0].toUpperCase() + t.substring(1), t)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? ListView.builder(padding: const EdgeInsets.all(16), itemCount: 5,
                    itemBuilder: (_, __) => Padding(padding: const EdgeInsets.only(bottom: 12), child: ShimmerLoading(width: double.infinity, height: 100, borderRadius: 14)))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _opps.isEmpty
                        ? const Center(child: Text('No opportunities found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _opps.length,
                            itemBuilder: (_, i) => _buildOppCard(_opps[i]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String? value) {
    final selected = _type == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) { setState(() => _type = value); _load(); },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: selected ? Colors.white : null, fontWeight: selected ? FontWeight.w600 : null),
      ),
    );
  }

  Widget _buildOppCard(Map opp) {
    final color = _typeColor(opp['type']);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text((opp['type'] ?? 'job').toString().toUpperCase(), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              if (opp['deadline'] != null)
                Text('Deadline: ${opp['deadline']}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
            ],
          ),
          const SizedBox(height: 10),
          Text(opp['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          if (opp['organization'] != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.business_outlined, size: 13, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(opp['organization'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
            ]),
          ],
          if (opp['location'] != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(opp['location'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
            ]),
          ],
          if (opp['description'] != null) ...[
            const SizedBox(height: 8),
            Text(opp['description'], maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ],
          if (opp['applicationUrl'] != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => launchUrl(Uri.parse(opp['applicationUrl']), mode: LaunchMode.externalApplication),
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
