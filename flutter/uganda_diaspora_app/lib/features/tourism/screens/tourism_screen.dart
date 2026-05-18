import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class TourismScreen extends StatefulWidget {
  const TourismScreen({super.key});

  @override
  State<TourismScreen> createState() => _TourismScreenState();
}

class _TourismScreenState extends State<TourismScreen> {
  List<dynamic> _attractions = [];
  bool _loading = true;
  String? _category;

  final _categories = ['National Park', 'Cultural Site', 'Wildlife', 'Historical', 'Beach', 'Mountain', 'Hotel'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient.instance.getTourism(category: _category);
      if (mounted) setState(() { _attractions = data['data'] ?? []; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tourism')),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.ugandaGradient),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Discover Uganda', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('The Pearl of Africa awaits you', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                _buildChip('All', null),
                ..._categories.map((c) => _buildChip(c, c)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? ListView.builder(padding: const EdgeInsets.all(16), itemCount: 4,
                    itemBuilder: (_, __) => Padding(padding: const EdgeInsets.only(bottom: 16), child: ShimmerLoading(width: double.infinity, height: 240, borderRadius: 16)))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _attractions.isEmpty
                        ? const Center(child: Text('No attractions found'))
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75,
                            ),
                            itemCount: _attractions.length,
                            itemBuilder: (_, i) => _buildAttractionCard(_attractions[i]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String? value) {
    final selected = _category == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) { setState(() => _category = value); _load(); },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: selected ? Colors.white : null, fontWeight: selected ? FontWeight.w600 : null),
      ),
    );
  }

  Widget _buildAttractionCard(Map attr) {
    return GestureDetector(
      onTap: () => context.push('/tourism/${attr['id']}'),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5))),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Stack(
              fit: StackFit.expand,
              children: [
                NetworkImageWidget(imageUrl: attr['imageUrl'], width: double.infinity, borderRadius: 0, fit: BoxFit.cover),
                if (attr['isFeatured'] == true)
                  Positioned(top: 8, right: 8, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(4)),
                    child: const Text('Featured', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.ugandaBlack)),
                  )),
              ],
            )),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(attr['name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (attr['location'] != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 2),
                    Expanded(child: Text(attr['location'], style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ],
                if (attr['category'] != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.tourismOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(attr['category'], style: const TextStyle(fontSize: 10, color: AppColors.tourismOrange, fontWeight: FontWeight.w500)),
                  ),
                ],
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
