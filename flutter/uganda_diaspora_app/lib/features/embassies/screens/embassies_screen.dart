import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? _region;

  final _searchCtrl = TextEditingController();

  static const _regions = [
    _Region('All',           null,             Icons.public_rounded,          Color(0xFF374151)),
    _Region('Africa',        'Africa',         Icons.terrain_rounded,          Color(0xFF16A34A)),
    _Region('Europe',        'Europe',         Icons.castle_rounded,           Color(0xFF1D4ED8)),
    _Region('N. America',    'North America',  Icons.landscape_rounded,        Color(0xFFD97706)),
    _Region('Middle East',   'Middle East',    Icons.mosque_rounded,           Color(0xFF7C3AED)),
    _Region('Asia',          'Asia',           Icons.temple_buddhist_rounded,  Color(0xFFDC2626)),
    _Region('Oceania',       'Oceania',        Icons.waves_rounded,            Color(0xFF0891B2)),
    _Region('S. America',    'South America',  Icons.forest_rounded,           Color(0xFF059669)),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient.instance.getEmbassies(
          search: _search.isNotEmpty ? _search : null,
          continent: _region,
          limit: 100);
      if (mounted) {
        setState(() {
          _embassies = data['data'] ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: RefreshIndicator(
          color: AppColors.darkOrange,
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              // ── App Bar ────────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: AppColors.primaryBlack,
                floating: true,
                snap: true,
                pinned: false,
                elevation: 0,
                leadingWidth: 0,
                leading: const SizedBox.shrink(),
                toolbarHeight: 140,
                flexibleSpace: SafeArea(
                  child: Container(
                    color: AppColors.primaryBlack,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Column(
                      children: [
                        // Title row
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: const Icon(Icons.arrow_back_rounded,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Embassies',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.3)),
                                  Text('Uganda diplomatic missions worldwide',
                                      style: TextStyle(
                                          color: Colors.white38, fontSize: 11)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_city_rounded,
                                      color: AppColors.darkOrange, size: 14),
                                  const SizedBox(width: 4),
                                  Text('${_embassies.length}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Search bar
                        Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search by country or city...',
                              hintStyle: const TextStyle(
                                  color: Colors.white38, fontSize: 14),
                              prefixIcon: const Icon(Icons.search_rounded,
                                  color: Colors.white38, size: 20),
                              suffixIcon: _search.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded,
                                          color: Colors.white38, size: 18),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _search = '');
                                        _load();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 13),
                            ),
                            onChanged: (v) {
                              setState(() => _search = v);
                              if (v.length >= 2 || v.isEmpty) _load();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Region filter ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.primaryBlack,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 52,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          children: _regions
                              .map((r) => _RegionChip(
                                    region: r,
                                    selected: _region == r.value,
                                    onTap: () {
                                      setState(() => _region = r.value);
                                      _load();
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                      Container(
                          height: 2,
                          decoration: const BoxDecoration(
                              gradient: AppColors.orangeGradient)),
                    ],
                  ),
                ),
              ),

              // ── Embassy list ───────────────────────────────────────────
              if (_loading)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => ShimmerLoading(
                          width: double.infinity,
                          height: 220,
                          borderRadius: 18),
                      childCount: 6,
                    ),
                  ),
                )
              else if (_embassies.isEmpty)
                const SliverFillRemaining(child: _EmptyEmbassies())
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.70,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) =>
                          _EmbassyCard(embassy: _embassies[i]),
                      childCount: _embassies.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Region data ────────────────────────────────────────────────────────────
class _Region {
  final String label;
  final String? value;
  final IconData icon;
  final Color color;
  const _Region(this.label, this.value, this.icon, this.color);
}

// ── Region chip ────────────────────────────────────────────────────────────
class _RegionChip extends StatelessWidget {
  final _Region region;
  final bool selected;
  final VoidCallback onTap;
  const _RegionChip(
      {required this.region, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? region.color : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? region.color : Colors.white15,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(region.icon,
                size: 13,
                color: selected ? Colors.white : Colors.white54),
            const SizedBox(width: 5),
            Text(
              region.label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Embassy card (grid) ────────────────────────────────────────────────────
class _EmbassyCard extends StatelessWidget {
  final dynamic embassy;
  const _EmbassyCard({required this.embassy});

  // Rough country → flag emoji mapping
  String _flagEmoji(String? country) {
    if (country == null) return '🏳️';
    final c = country.toLowerCase();
    if (c.contains('united kingdom') || c.contains('uk')) return '🇬🇧';
    if (c.contains('united states') || c.contains('usa')) return '🇺🇸';
    if (c.contains('canada')) return '🇨🇦';
    if (c.contains('germany')) return '🇩🇪';
    if (c.contains('france')) return '🇫🇷';
    if (c.contains('kenya')) return '🇰🇪';
    if (c.contains('south africa')) return '🇿🇦';
    if (c.contains('egypt')) return '🇪🇬';
    if (c.contains('nigeria')) return '🇳🇬';
    if (c.contains('ethiopia')) return '🇪🇹';
    if (c.contains('tanzania')) return '🇹🇿';
    if (c.contains('china')) return '🇨🇳';
    if (c.contains('japan')) return '🇯🇵';
    if (c.contains('india')) return '🇮🇳';
    if (c.contains('sweden')) return '🇸🇪';
    if (c.contains('norway')) return '🇳🇴';
    if (c.contains('denmark')) return '🇩🇰';
    if (c.contains('netherlands')) return '🇳🇱';
    if (c.contains('belgium')) return '🇧🇪';
    if (c.contains('italy')) return '🇮🇹';
    if (c.contains('spain')) return '🇪🇸';
    if (c.contains('russia')) return '🇷🇺';
    if (c.contains('saudi')) return '🇸🇦';
    if (c.contains('uae') || c.contains('emirates')) return '🇦🇪';
    if (c.contains('australia')) return '🇦🇺';
    if (c.contains('brazil')) return '🇧🇷';
    return '🌍';
  }

  Color _continentColor(String? continent) {
    switch (continent?.toLowerCase()) {
      case 'africa': return const Color(0xFF16A34A);
      case 'europe': return const Color(0xFF1D4ED8);
      case 'north america': return const Color(0xFFD97706);
      case 'middle east': return const Color(0xFF7C3AED);
      case 'asia': return const Color(0xFFDC2626);
      case 'oceania': return const Color(0xFF0891B2);
      case 'south america': return const Color(0xFF059669);
      default: return AppColors.embassyTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final country   = embassy['country']   as String? ?? '';
    final city      = embassy['city']      as String? ?? '';
    final continent = embassy['continent'] as String?;
    final imageUrl  = embassy['imageUrl']  as String?;
    final id        = embassy['id']        as int?    ?? 0;
    final color     = _continentColor(continent);

    return GestureDetector(
      onTap: () => context.push('/embassies/$id'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dividerLight),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            SizedBox(
              height: 130,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null && imageUrl.isNotEmpty
                      ? NetworkImageWidget(
                          imageUrl: imageUrl,
                          borderRadius: 0,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.flag_rounded)
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryBlack,
                                color.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                  // Gradient scrim
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xAA000000)],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                  // Flag emoji
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                      ),
                      child: Center(
                        child: Text(_flagEmoji(country),
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),
                  // City bottom
                  Positioned(
                    bottom: 8,
                    left: 10,
                    right: 50,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: Colors.white70, size: 12),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            city,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (continent != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: color.withOpacity(0.25)),
                        ),
                        child: Text(
                          continent,
                          style: TextStyle(
                              fontSize: 9.5,
                              color: color,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlack,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Text('Details',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(width: 3),
                              Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 11),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────
class _EmptyEmbassies extends StatelessWidget {
  const _EmptyEmbassies();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.embassyTeal.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_city_rounded,
                size: 48, color: AppColors.embassyTeal),
          ),
          const SizedBox(height: 16),
          const Text('No embassies found',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight)),
          const SizedBox(height: 6),
          const Text('Try a different region or search term',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}
