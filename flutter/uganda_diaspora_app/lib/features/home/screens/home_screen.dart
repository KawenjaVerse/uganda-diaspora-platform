import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _userName = 'Ugandan';

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
        ApiClient.instance.getMe().catchError((_) => <String, dynamic>{}),
      ]);
      if (mounted) {
        final me = results[3] as Map<String, dynamic>;
        final fullName = (me['fullName'] ?? me['name'] ?? '') as String;
        setState(() {
          _news = results[0]['data'] ?? [];
          _events = results[1]['data'] ?? [];
          _mdas = results[2] as List;
          _userName = fullName.isNotEmpty ? fullName.split(' ').first : 'Ugandan';
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
      backgroundColor: const Color(0xFFF5F5F0),
      body: RefreshIndicator(
        color: AppColors.ugandaRed,
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            _buildHeroAppBar(context),
            SliverToBoxAdapter(child: _buildStatehouseBanner(context)),
            SliverToBoxAdapter(child: _buildQuickAccess(context)),
            SliverToBoxAdapter(child: _buildMdaSection(context)),
            SliverToBoxAdapter(child: _buildNewsSection(context)),
            SliverToBoxAdapter(child: _buildEventsSection(context)),
            // Space above FAB
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  // ── Hero App Bar ───────────────────────────────────────────────────────────
  Widget _buildHeroAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 230,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black,
      systemOverlayStyle: const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.fade,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Uganda flag stripe bands (full background)
            Column(children: [
              Expanded(child: Container(color: Colors.black)),
              Expanded(child: Container(color: AppColors.ugandaYellow)),
              Expanded(child: Container(color: AppColors.ugandaRed)),
              Expanded(child: Container(color: Colors.black)),
              Expanded(child: Container(color: AppColors.ugandaYellow)),
              Expanded(child: Container(color: AppColors.ugandaRed)),
            ]),
            // Dark overlay
            Container(color: Colors.black.withOpacity(0.72)),
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: coat of arms + title + icons
                    Row(
                      children: [
                        // Mini coat of arms badge
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.ugandaYellow, width: 2),
                          ),
                          child: ClipOval(
                            child: Column(children: [
                              Expanded(child: Container(color: Colors.black)),
                              Expanded(child: Container(color: AppColors.ugandaYellow)),
                              Expanded(child: Container(color: AppColors.ugandaRed)),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UGANDA', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 3)),
                            Text('DIASPORA', style: TextStyle(color: AppColors.ugandaYellow, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 3)),
                          ],
                        ),
                        const Spacer(),
                        // Statehouse message icon
                        _AppBarIcon(
                          icon: Icons.campaign_rounded,
                          color: AppColors.ugandaYellow,
                          badge: true,
                          onTap: () => context.push('/statehouse'),
                          tooltip: 'Statehouse Message',
                        ),
                        const SizedBox(width: 4),
                        // Notifications icon
                        _AppBarIcon(
                          icon: Icons.notifications_outlined,
                          onTap: () => context.go('/notifications'),
                          tooltip: 'Notifications',
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Greeting
                    Row(
                      children: [
                        Container(width: 3, height: 36, color: AppColors.ugandaYellow, margin: const EdgeInsets.only(right: 10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Akwaaba, $_userName! 👋',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Connecting Ugandans Worldwide',
                                style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Stats chips
                    Row(
                      children: [
                        _StatChip(label: '3M+', sub: 'Diaspora'),
                        const SizedBox(width: 8),
                        _StatChip(label: '54', sub: 'Missions'),
                        const SizedBox(width: 8),
                        _StatChip(label: '\$1.2B', sub: 'Remittances'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.ugandaYellow, width: 1.5)),
              child: ClipOval(
                child: Column(children: [
                  Expanded(child: Container(color: Colors.black)),
                  Expanded(child: Container(color: AppColors.ugandaYellow)),
                  Expanded(child: Container(color: AppColors.ugandaRed)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Uganda Diaspora', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ── Statehouse Banner ──────────────────────────────────────────────────────
  Widget _buildStatehouseBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/statehouse'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: const BorderSide(color: AppColors.ugandaYellow, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            // Icon section
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                color: Colors.black,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Flag mini bands
                  Column(children: [
                    Expanded(child: Container(color: Colors.black)),
                    Expanded(child: Container(color: AppColors.ugandaYellow)),
                    Expanded(child: Container(color: AppColors.ugandaRed)),
                  ]),
                  Container(color: Colors.black.withOpacity(0.5)),
                  const Icon(Icons.campaign_rounded, color: AppColors.ugandaYellow, size: 32),
                ],
              ),
            ),
            // Text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.ugandaRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('NEW MESSAGE', style: TextStyle(color: AppColors.ugandaRed, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Message from the Head of Diaspora Affairs',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.3),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Read the official statement from State House, Kampala',
                      style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            // Arrow
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick Access Grid ──────────────────────────────────────────────────────
  Widget _buildQuickAccess(BuildContext context) {
    final items = [
      _QuickItem('Tourism', Icons.landscape_rounded, AppColors.tourismOrange, '/tourism'),
      _QuickItem('Webinars', Icons.play_circle_outline_rounded, AppColors.webinarPurple, '/webinars'),
      _QuickItem('Events', Icons.event_rounded, AppColors.ugandaRed, '/events'),
      _QuickItem('Opportunities', Icons.work_outline_rounded, AppColors.ugandaYellow, '/opportunities'),
      _QuickItem('Embassies', Icons.location_city_rounded, AppColors.embassyTeal, '/embassies'),
      _QuickItem('Community', Icons.people_rounded, Colors.black, '/community'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Quick Access'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: items.map((item) => _buildQuickItem(context, item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickItem(BuildContext context, _QuickItem item) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            const SizedBox(height: 7),
            Text(
              item.label,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── MDA Section ────────────────────────────────────────────────────────────
  Widget _buildMdaSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: AppStrings.governmentMdas, route: null),
          const SizedBox(height: 12),
          if (_loading)
            Column(children: List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ShimmerLoading(width: double.infinity, height: 260),
            )))
          else if (_mdas.isEmpty)
            _emptyState('No MDAs available', Icons.account_balance_outlined)
          else
            Column(
              children: _mdas.map((mda) => _buildMdaCard(context, mda)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMdaCard(BuildContext context, Map<String, dynamic> mda) {
    final name = mda['name'] as String? ?? 'Ministry';
    final description = mda['description'] as String? ?? 'Government Ministry, Department or Agency serving Ugandans.';
    final website = mda['website'] as String? ?? '';
    final category = mda['category'] as String? ?? 'Government';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image section (styled Uganda-flag header) ──────────────
          Container(
            height: 130,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Uganda flag diagonal stripes
                CustomPaint(painter: _MdaHeaderPainter()),
                // Dark overlay
                Container(color: Colors.black.withOpacity(0.42)),
                // Category chip top-left
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                    ),
                    child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
                // Center icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                    ),
                    child: Icon(_getMdaIcon(category), color: Colors.white, size: 34),
                  ),
                ),
              ],
            ),
          ),

          // ── Title ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: Colors.black87, height: 1.3),
            ),
          ),

          // ── Description ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13, height: 1.55),
            ),
          ),

          // ── Divider + Visit button ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                if (website.isNotEmpty) ...[
                  Icon(Icons.link_rounded, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      website.replaceFirst('https://', '').replaceFirst('http://', ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                    ),
                  ),
                ] else
                  const Spacer(),
                const SizedBox(width: 8),
                // Visit button
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate or open URL
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Visiting $name...'),
                        backgroundColor: Colors.black,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ugandaRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                  label: const Text('Visit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── News Section ───────────────────────────────────────────────────────────
  Widget _buildNewsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Latest News', route: '/news', onSeeAll: () => context.go('/news')),
          const SizedBox(height: 12),
          if (_loading)
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ShimmerLoading(width: 230, height: 220, borderRadius: 16),
                ),
              ),
            )
          else if (_news.isEmpty)
            _emptyState('No news available', Icons.newspaper_outlined)
          else
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _news.length,
                itemBuilder: (context, i) => _buildNewsCard(context, _news[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => context.push('/news/${item['id']}'),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkImageWidget(
              imageUrl: item['imageUrl'],
              height: 130,
              width: double.infinity,
              borderRadius: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item['category'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.ugandaRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        item['category'],
                        style: const TextStyle(fontSize: 10, color: AppColors.ugandaRed, fontWeight: FontWeight.w700),
                      ),
                    ),
                  const SizedBox(height: 7),
                  Text(
                    item['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.35),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 3),
                      Text(
                        _formatDate(item['publishedAt']),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Events Section ─────────────────────────────────────────────────────────
  Widget _buildEventsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Upcoming Events', route: '/events', onSeeAll: () => context.go('/events')),
          const SizedBox(height: 12),
          if (_loading)
            Column(children: List.generate(2, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ShimmerLoading(width: double.infinity, height: 80),
            )))
          else if (_events.isEmpty)
            _emptyState('No upcoming events', Icons.event_rounded)
          else
            Column(
              children: _events.take(3).map((event) => _buildEventTile(context, event)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, Map<String, dynamic> event) {
    final isVirtual = event['isVirtual'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Date block
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
            ),
            child: Column(
              children: [
                Text(
                  _getEventDay(event['startDate']),
                  style: const TextStyle(color: AppColors.ugandaYellow, fontSize: 22, fontWeight: FontWeight.w900, height: 1),
                ),
                Text(
                  _getEventMonth(event['startDate']),
                  style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isVirtual ? Icons.videocam_outlined : Icons.location_on_outlined,
                        size: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          isVirtual ? 'Virtual Event' : (event['location'] ?? 'Uganda'),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Virtual badge or arrow
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: isVirtual
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.ugandaRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Online', style: TextStyle(fontSize: 10, color: AppColors.ugandaRed, fontWeight: FontWeight.w700)),
                  )
                : const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight, size: 20),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _emptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }

  IconData _getMdaIcon(String category) {
    final c = category.toLowerCase();
    if (c.contains('foreign') || c.contains('affairs')) return Icons.public_rounded;
    if (c.contains('health')) return Icons.local_hospital_rounded;
    if (c.contains('education')) return Icons.school_rounded;
    if (c.contains('finance') || c.contains('treasury')) return Icons.account_balance_rounded;
    if (c.contains('trade') || c.contains('commerce')) return Icons.storefront_rounded;
    if (c.contains('labour') || c.contains('employment')) return Icons.work_rounded;
    if (c.contains('tourism')) return Icons.landscape_rounded;
    if (c.contains('agriculture')) return Icons.grass_rounded;
    if (c.contains('energy') || c.contains('mineral')) return Icons.bolt_rounded;
    if (c.contains('justice') || c.contains('court')) return Icons.gavel_rounded;
    if (c.contains('ict') || c.contains('technology')) return Icons.computer_rounded;
    if (c.contains('infrastructure') || c.contains('transport')) return Icons.directions_transit_rounded;
    return Icons.account_balance_outlined;
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final d = DateTime.parse(date.toString());
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '';
    }
  }

  String _getEventDay(dynamic date) {
    if (date == null) return '--';
    try {
      return DateTime.parse(date.toString()).day.toString();
    } catch (_) {
      return '--';
    }
  }

  String _getEventMonth(dynamic date) {
    if (date == null) return '---';
    try {
      final d = DateTime.parse(date.toString());
      const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      return months[d.month - 1];
    } catch (_) {
      return '---';
    }
  }
}

// ── MDA Header Painter (diagonal flag stripes) ─────────────────────────────
class _MdaHeaderPainter extends CustomPainter {
  static const _colors = [Colors.black, AppColors.ugandaYellow, AppColors.ugandaRed];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bandW = w / 4;

    for (int i = 0; i < 6; i++) {
      final paint = Paint()..color = _colors[i % 3];
      final x0 = i * bandW - h * 0.7;
      final path = Path()
        ..moveTo(x0, 0)
        ..lineTo(x0 + bandW, 0)
        ..lineTo(x0 + bandW + h * 0.7, h)
        ..lineTo(x0 + h * 0.7, h)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Section Header ─────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? route;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.route, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.ugandaYellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87)),
        const Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('See all', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }
}

// ── App Bar Icon Button ────────────────────────────────────────────────────
class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool badge;
  final VoidCallback onTap;
  final String tooltip;

  const _AppBarIcon({
    required this.icon,
    this.color = Colors.white,
    this.badge = false,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            if (badge)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.ugandaRed,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 1.5)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Chip ──────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String sub;

  const _StatChip({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
          Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Quick Item model ───────────────────────────────────────────────────────
class _QuickItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _QuickItem(this.label, this.icon, this.color, this.route);
}

