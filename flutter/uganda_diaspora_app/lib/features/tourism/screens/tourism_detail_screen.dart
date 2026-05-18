import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';

class TourismDetailScreen extends StatefulWidget {
  final int id;
  const TourismDetailScreen({super.key, required this.id});

  @override
  State<TourismDetailScreen> createState() => _TourismDetailScreenState();
}

class _TourismDetailScreenState extends State<TourismDetailScreen> {
  Map<String, dynamic>? _attr;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.getTourismById(widget.id);
      if (mounted) setState(() { _attr = Map<String, dynamic>.from(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _attr == null
              ? const Center(child: Text('Not found'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 280,
                      pinned: true,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(_attr!['name'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        background: NetworkImageWidget(imageUrl: _attr!['imageUrl'], width: double.infinity, borderRadius: 0, fit: BoxFit.cover),
                        collapseMode: CollapseMode.fade,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (_attr!['category'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.tourismOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: Text(_attr!['category'], style: const TextStyle(color: AppColors.tourismOrange, fontWeight: FontWeight.w600, fontSize: 12)),
                                  ),
                                const Spacer(),
                                if (_attr!['isFeatured'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(6)),
                                    child: const Text('Featured', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.ugandaBlack)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_attr!['location'] != null)
                              Row(children: [
                                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                                const SizedBox(width: 6),
                                Text(_attr!['location'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              ]),
                            const SizedBox(height: 16),
                            if (_attr!['description'] != null) ...[
                              const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 10),
                              Text(_attr!['description'], style: const TextStyle(fontSize: 15, height: 1.7)),
                              const SizedBox(height: 20),
                            ],
                            if (_attr!['openingHours'] != null) _buildDetail(Icons.access_time_rounded, 'Opening Hours', _attr!['openingHours']),
                            if (_attr!['entryFee'] != null) _buildDetail(Icons.attach_money_rounded, 'Entry Fee', _attr!['entryFee']),
                            if (_attr!['contactPhone'] != null) _buildDetail(Icons.phone_outlined, 'Contact', _attr!['contactPhone']),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ]),
        ],
      ),
    );
  }
}
