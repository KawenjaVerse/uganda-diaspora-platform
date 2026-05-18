import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _news = [];
  List<dynamic> _events = [];
  List<dynamic> _mdas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiClient.instance.getNews(limit: 5, featured: true),
        ApiClient.instance.getEvents(upcoming: true),
        ApiClient.instance.getMdas(),
      ]);
      if (mounted) {
        setState(() {
          _news = results[0]['data'] ?? [];
          _events = results[1]['data'] ?? [];
          _mdas = results[2] as List;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            _buildHeroAppBar(context),
            SliverToBoxAdapter(child: _buildQuickAccess(context)),
            SliverToBoxAdapter(child: _buildSection(context, 'Latest News', '/news', _buildNewsList())),
            SliverToBoxAdapter(child: _buildSection(context, 'Upcoming Events', '/events', _buildEventsList())),
            SliverToBoxAdapter(child: _buildMdas(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.ugandaGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      const Text('Uganda Diaspora', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.go('/notifications'),
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome back,\nConnecting Ugandans Worldwide',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: const Text('Uganda Diaspora', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        collapseMode: CollapseMode.fade,
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    final items = [
      ('Tourism', Icons.landscape_rounded, AppColors.tourismOrange, '/tourism'),
      ('Webinars', Icons.play_circle_outline_rounded, AppColors.webinarPurple, '/webinars'),
      ('Opportunities', Icons.work_outline_rounded, AppColors.opportunityGold, '/opportunities'),
      ('MDAs', Icons.account_balance_outlined, AppColors.embassyTeal, '/'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Access', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: items.map((item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => context.go(item.$4),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: item.$3.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: item.$3.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(item.$2, color: item.$3, size: 26),
                        const SizedBox(height: 6),
                        Text(item.$1, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: item.$3), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String route, Widget content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () => context.go(route),
                child: const Text('See all', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    if (_loading) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ShimmerLoading(width: 220, height: 200, borderRadius: 16),
          ),
        ),
      );
    }

    if (_news.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('No news available', style: TextStyle(color: AppColors.textSecondaryLight)),
      ));
    }

    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _news.length,
        itemBuilder: (context, i) {
          final item = _news[i];
          return GestureDetector(
            onTap: () => context.push('/news/${item['id']}'),
            child: Container(
              width: 230,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetworkImageWidget(imageUrl: item['imageUrl'], height: 120, width: double.infinity, borderRadius: 0),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item['category'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(item['category'], style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w500)),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          item['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsList() {
    if (_loading) {
      return Column(children: List.generate(2, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ShimmerLoading(width: double.infinity, height: 72),
      )));
    }

    if (_events.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('No upcoming events', style: TextStyle(color: AppColors.textSecondaryLight)),
      ));
    }

    return Column(
      children: (_events.take(3).toList()).map((event) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.event_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (event['location'] != null)
                    Text(event['location'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            if (event['isVirtual'] == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text('Virtual', style: TextStyle(fontSize: 10, color: AppColors.info, fontWeight: FontWeight.w500)),
              ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildMdas(BuildContext context) {
    if (_loading || _mdas.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.governmentMdas, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _mdas.length,
              itemBuilder: (_, i) {
                final mda = _mdas[i];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                        ),
                        child: mda['logoUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: NetworkImageWidget(imageUrl: mda['logoUrl'], width: 56, height: 56, fallbackIcon: Icons.account_balance_outlined),
                              )
                            : const Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mda['name'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
