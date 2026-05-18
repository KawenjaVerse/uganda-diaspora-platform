import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class EmbassiesScreen extends StatefulWidget {
  const EmbassiesScreen({super.key});

  @override
  State<EmbassiesScreen> createState() => _EmbassiesScreenState();
}

class _EmbassiesScreenState extends State<EmbassiesScreen> {
  List<dynamic> _embassies = [];
  bool _loading = true;
  String _search = '';
  String? _continent;
  final _searchController = TextEditingController();

  final _continents = ['Africa', 'Asia', 'Europe', 'North America', 'South America', 'Oceania'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient.instance.getEmbassies(search: _search, continent: _continent, limit: 100);
      if (mounted) setState(() { _embassies = data['data'] ?? []; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Embassies')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by country...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () {
                        _searchController.clear();
                        setState(() => _search = '');
                        _load();
                      })
                    : null,
              ),
              onChanged: (v) {
                setState(() => _search = v);
                _load();
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                _buildContChip('All', null),
                ..._continents.map((c) => _buildContChip(c, c)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 6,
                    itemBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShimmerLoading(width: double.infinity, height: 80, borderRadius: 14),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _embassies.isEmpty
                        ? const Center(child: Text('No embassies found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _embassies.length,
                            itemBuilder: (_, i) => _buildEmbassyTile(_embassies[i]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContChip(String label, String? value) {
    final selected = _continent == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) {
          setState(() => _continent = value);
          _load();
        },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: selected ? Colors.white : null, fontWeight: selected ? FontWeight.w600 : null),
      ),
    );
  }

  Widget _buildEmbassyTile(Map embassy) {
    return GestureDetector(
      onTap: () => context.push('/embassies/${embassy['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: NetworkImageWidget(imageUrl: embassy['imageUrl'], width: 56, height: 56, fallbackIcon: Icons.flag_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Uganda Embassy in ${embassy['country']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 2),
                    Text(embassy['city'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                  ]),
                  if (embassy['continent'] != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.embassyTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(embassy['continent'], style: const TextStyle(fontSize: 10, color: AppColors.embassyTeal, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }
}
