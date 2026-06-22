import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _news     = [];
  List<dynamic> _mdas     = [];
  List<dynamic> _tourism  = [];
  List<dynamic> _webinars = [];
  List<dynamic> _events   = [];
  bool _loading    = true;
  bool _hasError   = false;
  String _userName = '';
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() { _loading = true; _hasError = false; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      _isLoggedIn = token != null && token.isNotEmpty;

      final results = await Future.wait<dynamic>([
        ApiClient.instance.getNews(limit: 10),
        ApiClient.instance.getMdas(),
        ApiClient.instance.getTourism(limit: 6),
        ApiClient.instance.getWebinars(upcoming: true),
        ApiClient.instance.getEvents(upcoming: true),
      ]);

      if (mounted) {
        setState(() {
          _news     = (results[0] as Map<String, dynamic>)['data'] ?? [];
          _mdas     = results[1] as List<dynamic>;
          _tourism  = (results[2] as Map<String, dynamic>)['data'] ?? [];
          _webinars = (results[3] as Map<String, dynamic>)['data'] ?? [];
          _events   = (results[4] as Map<String, dynamic>)['data'] ?? [];
          _loading  = false;
        });
      }

      if (_isLoggedIn) {
        try {
          final me = await ApiClient.instance.getMe();
          if (mounted) setState(() => _userName = me['fullName'] ?? '');
        } catch (_) {}
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _hasError = true; });
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: RefreshIndicator(
          color: AppColors.darkOrange,
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // ── App Bar ────────────────────────────────────────────────
              _HomeAppBar(
                greeting: _greeting,
                userName: _userName,
                isLoggedIn: _isLoggedIn,
              ),

              // ── Error banner ───────────────────────────────────────────
              if (_hasError)
                SliverToBoxAdapter(child: _ErrorBanner(onRetry: _loadData)),

              // ── 1. Trending News ───────────────────────────────────────
              SliverToBoxAdapter(
                child: _loading
                    ? _NewsSkeleton()
                    : _TrendingNewsSection(news: _news),
              ),

              // ── 2. Announcements ───────────────────────────────────────
              SliverToBoxAdapter(
                child: _AnnouncementsSection(events: _events),
              ),

              // ── 3. Quick Access Services ───────────────────────────────
              const SliverToBoxAdapter(child: _QuickAccessSection()),

              // ── 4. Statehouse Message ──────────────────────────────────
              const SliverToBoxAdapter(child: _StatehouseCard()),

              // ── 5. MDAs ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _loading
                    ? _RowSkeleton()
                    : _MdaSection(mdas: _mdas),
              ),

              // ── 6. Tourism Showcase ────────────────────────────────────
              SliverToBoxAdapter(
                child: _loading
                    ? _RowSkeleton()
                    : _TourismSection(tourism: _tourism),
              ),

              // ── 7. Webinars ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _loading
                    ? _RowSkeleton()
                    : _WebinarSection(webinars: _webinars),
              ),

              // ── 8. Community Highlight ─────────────────────────────────
              SliverToBoxAdapter(
                child: _CommunityHighlight(isLoggedIn: _isLoggedIn),
              ),

              // FAB + nav bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// APP BAR
// ═══════════════════════════════════════════════════════════════════════════
class _HomeAppBar extends StatelessWidget {
  final String greeting;
  final String userName;
  final bool isLoggedIn;
  const _HomeAppBar({required this.greeting, required this.userName, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.primaryBlack,
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      toolbarHeight: 72,
      flexibleSpace: SafeArea(
        child: Container(
          color: AppColors.primaryBlack,
          padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
          child: Row(
            children: [
              // Logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.darkOrange, width: 2),
                  boxShadow: [BoxShadow(color: AppColors.darkOrange.withOpacity(0.3), blurRadius: 10)],
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/coat_of_arms.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.flag_rounded, color: AppColors.darkOrange, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn && userName.isNotEmpty
                          ? '$greeting, ${userName.split(' ').first}!'
                          : 'Uganda Diaspora',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Connecting Ugandans Worldwide',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Search icon
              _AppBarIcon(
                icon: Icons.search_rounded,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  _snack('Search coming soon'),
                ),
              ),
              const SizedBox(width: 6),
              // Notifications (with badge)
              Stack(
                children: [
                  _AppBarIcon(
                    icon: Icons.notifications_outlined,
                    onTap: () => context.go('/notifications'),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.deepRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. TRENDING NEWS
// ═══════════════════════════════════════════════════════════════════════════
class _TrendingNewsSection extends StatelessWidget {
  final List<dynamic> news;
  const _TrendingNewsSection({required this.news});

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) return const SizedBox.shrink();
    final featured = news.first;
    final trending = news.length > 1 ? news.sublist(1) : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'Trending News',
          accentColor: AppColors.darkOrange,
          action: 'See all',
          onAction: () => context.go('/news'),
        ),
        const SizedBox(height: 12),

        // Hero card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _HeroNewsCard(item: featured),
        ),

        // Horizontal scroll
        if (trending.isNotEmpty) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 186,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: trending.length,
              itemBuilder: (_, i) => _SmallNewsCard(item: trending[i]),
            ),
          ),
        ],
        const SizedBox(height: 28),
      ],
    );
  }
}

class _HeroNewsCard extends StatelessWidget {
  final dynamic item;
  const _HeroNewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl  = item['imageUrl']    as String?;
    final title     = item['title']       as String? ?? 'No title';
    final category  = item['category']    as String? ?? 'News';
    final publishedAt = item['publishedAt'] as String?;
    final id        = item['id']          as int?    ?? 0;

    DateTime? pubDate;
    try { pubDate = publishedAt != null ? DateTime.parse(publishedAt) : null; } catch (_) {}

    return GestureDetector(
      onTap: () => context.push('/news/$id'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 272,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background
              imageUrl != null && imageUrl.isNotEmpty
                  ? NetworkImageWidget(imageUrl: imageUrl, borderRadius: 0, fit: BoxFit.cover)
                  : Container(decoration: const BoxDecoration(gradient: AppColors.heroGradient)),

              // Scrim
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x33000000), Color(0xDD000000)],
                    stops: [0.25, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Badge('TRENDING', AppColors.deepRed),
                        const Spacer(),
                        _IconPill(icon: Icons.share_outlined, onTap: () => Share.share(title)),
                        const SizedBox(width: 6),
                        _IconPill(icon: Icons.bookmark_border_rounded, onTap: () {}),
                      ],
                    ),
                    const Spacer(),
                    _Badge(category.toUpperCase(), AppColors.darkOrange),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          letterSpacing: -0.3),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: Colors.white54, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          pubDate != null ? timeago.format(pubDate) : 'Just now',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const Spacer(),
                        const Row(
                          children: [
                            Text('Read story', style: TextStyle(color: AppColors.darkOrange, fontSize: 12, fontWeight: FontWeight.w700)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, color: AppColors.darkOrange, size: 13),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallNewsCard extends StatelessWidget {
  final dynamic item;
  const _SmallNewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl    = item['imageUrl']    as String?;
    final title       = item['title']       as String? ?? '';
    final category    = item['category']    as String? ?? 'News';
    final publishedAt = item['publishedAt'] as String?;
    final id          = item['id']          as int?    ?? 0;

    DateTime? pubDate;
    try { pubDate = publishedAt != null ? DateTime.parse(publishedAt) : null; } catch (_) {}

    return GestureDetector(
      onTap: () => context.push('/news/$id'),
      child: Container(
        width: 198,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerLight),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 104,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkImageWidget(imageUrl: imageUrl, borderRadius: 0, fit: BoxFit.cover),
                  Positioned(
                    top: 8, left: 8,
                    child: _Badge(category.toUpperCase(), AppColors.darkOrange, fontSize: 8.5),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.35),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Text(
                      pubDate != null ? timeago.format(pubDate) : '',
                      style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight),
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

// ═══════════════════════════════════════════════════════════════════════════
// 2. ANNOUNCEMENTS
// ═══════════════════════════════════════════════════════════════════════════
class _AnnouncementsSection extends StatelessWidget {
  final List<dynamic> events;
  const _AnnouncementsSection({required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      color: AppColors.primaryBlack,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.campaign_rounded, color: AppColors.darkOrange, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Official Announcements',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    Text('State House · Diaspora Unit',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.deepRed.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.deepRed.withOpacity(0.4)),
                ),
                child: const Text('LIVE',
                    style: TextStyle(
                        color: AppColors.deepRed,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Pinned card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkOrange.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.darkOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.push_pin_rounded, color: AppColors.darkOrange, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome to the Uganda Diaspora Portal',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text(
                        'Connect with government services, stay informed, and engage with Ugandans across the globe.',
                        style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Upcoming events
          if (events.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...events.take(2).map((e) => _EventRow(item: e)),
          ],
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final dynamic item;
  const _EventRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final title     = item['title']     as String? ?? '';
    final startDate = item['startDate'] as String?;
    DateTime? dt;
    try { dt = startDate != null ? DateTime.parse(startDate) : null; } catch (_) {}

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dt != null ? DateFormat('d').format(dt) : '--',
                    style: const TextStyle(
                        color: AppColors.darkOrange, fontSize: 14, fontWeight: FontWeight.w900, height: 1)),
                Text(dt != null ? DateFormat('MMM').format(dt) : '--',
                    style: const TextStyle(color: Colors.white54, fontSize: 9, height: 1)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white30, size: 16),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. QUICK ACCESS
// ═══════════════════════════════════════════════════════════════════════════
class _QuickAccessSection extends StatelessWidget {
  const _QuickAccessSection();

  static const _items = [
    _QAItem('Embassies',     Icons.location_city_rounded,         Color(0xFF0891B2), '/embassies'),
    _QAItem('Tourism',       Icons.landscape_rounded,              Color(0xFF16A34A), '/tourism'),
    _QAItem('Webinars',      Icons.video_camera_front_rounded,     Color(0xFF7C3AED), '/webinars'),
    _QAItem('Opportunities', Icons.work_outline_rounded,           Color(0xFFD97706), '/opportunities'),
    _QAItem('Events',        Icons.event_rounded,                  Color(0xFFB91C1C), '/events'),
    _QAItem('Community',     Icons.people_rounded,                 Color(0xFF0891B2), '/community'),
    _QAItem('Services',      Icons.miscellaneous_services_rounded, Color(0xFF374151), '/'),
    _QAItem('Emergency',     Icons.emergency_rounded,              Color(0xFFDC2626), '/'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Quick Access', accentColor: AppColors.primaryBlack),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.84,
            ),
            itemCount: _items.length,
            itemBuilder: (context, i) => _QACard(item: _items[i]),
          ),
        ],
      ),
    );
  }
}

class _QAItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _QAItem(this.label, this.icon, this.color, this.route);
}

class _QACard extends StatelessWidget {
  final _QAItem item;
  const _QACard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.dividerLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(height: 7),
            Text(
              item.label,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: -0.1),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. STATEHOUSE MESSAGE
// ═══════════════════════════════════════════════════════════════════════════
class _StatehouseCard extends StatelessWidget {
  const _StatehouseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C0A00), Color(0xFF121212)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.darkOrange.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          // Top orange stripe
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.darkOrange.withOpacity(0.12),
                        border: Border.all(color: AppColors.darkOrange, width: 2),
                      ),
                      child: const Icon(Icons.person_rounded, color: AppColors.darkOrange, size: 32),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Message from the Diaspora Unit',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                          SizedBox(height: 3),
                          Text('Office of the President · State House Uganda',
                              style: TextStyle(color: AppColors.darkOrange, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    _Badge('OFFICIAL', AppColors.darkOrange, fontSize: 8.5),
                  ],
                ),

                const SizedBox(height: 14),

                const Text(
                  '"As Ugandans living abroad, you are our greatest ambassadors. The Diaspora Platform is your gateway to stay connected with home, access services, and contribute to Uganda\'s development."',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.65, fontStyle: FontStyle.italic),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () => context.push('/statehouse'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          child: const Text('Read Full Message'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24, width: 1),
                          foregroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        icon: const Icon(Icons.play_circle_outline_rounded, size: 15),
                        label: const Text('Video', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
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

// ═══════════════════════════════════════════════════════════════════════════
// 5. MDAs
// ═══════════════════════════════════════════════════════════════════════════
class _MdaSection extends StatelessWidget {
  final List<dynamic> mdas;
  const _MdaSection({required this.mdas});

  @override
  Widget build(BuildContext context) {
    if (mdas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(
            children: [
              _SectionHeader(title: 'Government MDAs', accentColor: AppColors.deepRed),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.deepRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.deepRed.withOpacity(0.2)),
                ),
                child: Text('${mdas.length} agencies',
                    style: const TextStyle(color: AppColors.deepRed, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 148,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mdas.length,
            itemBuilder: (_, i) => _MdaCard(item: mdas[i]),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _MdaCard extends StatelessWidget {
  final dynamic item;
  const _MdaCard({required this.item});

  Future<void> _openWebsite(BuildContext context) async {
    final website = item['website'] as String?;
    if (website == null || website.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No website available for this agency')),
      );
      return;
    }
    final url = website.startsWith('http') ? website : 'https://$website';
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name        = item['name']        as String? ?? '';
    final description = item['description'] as String? ?? '';
    final hasWebsite  = (item['website'] as String?)?.isNotEmpty ?? false;

    return GestureDetector(
      onTap: () => _openWebsite(context),
      child: Container(
        width: 205,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerLight),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flag stripe header
            Row(
              children: [
                AppColors.ugandaBlack,
                AppColors.ugandaYellow,
                AppColors.ugandaRed,
              ].map((c) => Expanded(child: Container(height: 44, color: c))).toList(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(description,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryLight, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasWebsite ? AppColors.primaryBlack : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_browser_rounded, size: 10,
                                color: hasWebsite ? Colors.white : Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text('Visit Website',
                                style: TextStyle(
                                  color: hasWebsite ? Colors.white : Colors.grey.shade500,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ),
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

// ═══════════════════════════════════════════════════════════════════════════
// 6. TOURISM SHOWCASE
// ═══════════════════════════════════════════════════════════════════════════
class _TourismSection extends StatelessWidget {
  final List<dynamic> tourism;
  const _TourismSection({required this.tourism});

  @override
  Widget build(BuildContext context) {
    if (tourism.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: _SectionHeader(
            title: 'Explore Uganda',
            accentColor: const Color(0xFF16A34A),
            action: 'See all',
            onAction: () => context.go('/tourism'),
          ),
        ),
        SizedBox(
          height: 205,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tourism.length,
            itemBuilder: (_, i) => _TourismCard(item: tourism[i]),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _TourismCard extends StatelessWidget {
  final dynamic item;
  const _TourismCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final name     = item['name']     as String? ?? '';
    final imageUrl = item['imageUrl'] as String?;
    final category = item['category'] as String? ?? 'Tourism';
    final id       = item['id']       as int?    ?? 0;

    return GestureDetector(
      onTap: () => context.push('/tourism/$id'),
      child: Container(
        width: 174,
        margin: const EdgeInsets.only(right: 12),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.primaryBlack,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkImageWidget(imageUrl: imageUrl, borderRadius: 0, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xEE000000)],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 10, left: 10,
              child: _Badge(category, const Color(0xFF16A34A), fontSize: 9),
            ),
            Positioned(
              bottom: 12, left: 12, right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, height: 1.3),
                      maxLines: 2),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(Icons.explore_rounded, color: Colors.white54, size: 13),
                      SizedBox(width: 4),
                      Text('Explore', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
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
}

// ═══════════════════════════════════════════════════════════════════════════
// 7. WEBINARS
// ═══════════════════════════════════════════════════════════════════════════
class _WebinarSection extends StatelessWidget {
  final List<dynamic> webinars;
  const _WebinarSection({required this.webinars});

  @override
  Widget build(BuildContext context) {
    if (webinars.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Upcoming Webinars',
            accentColor: const Color(0xFF7C3AED),
            action: 'See all',
            onAction: () => context.go('/webinars'),
          ),
          const SizedBox(height: 14),
          ...webinars.take(3).map((w) => _WebinarRow(item: w)),
        ],
      ),
    );
  }
}

class _WebinarRow extends StatelessWidget {
  final dynamic item;
  const _WebinarRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final title       = item['title']       as String? ?? '';
    final scheduledAt = item['scheduledAt'] as String?;
    final speakerName = item['speakerName'] as String?;
    final thumbnailUrl= item['thumbnailUrl']as String?;

    DateTime? dt;
    try { dt = scheduledAt != null ? DateTime.parse(scheduledAt) : null; } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 66,
              height: 66,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  thumbnailUrl != null && thumbnailUrl.isNotEmpty
                      ? NetworkImageWidget(imageUrl: thumbnailUrl, borderRadius: 0)
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                            ),
                          ),
                        ),
                  Container(color: Colors.black26),
                  const Center(child: Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 30)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (speakerName != null) ...[
                  const SizedBox(height: 4),
                  Text(speakerName,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                ],
                if (dt != null) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 11, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 4),
                      Text(DateFormat('MMM d, yyyy · h:mm a').format(dt),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7C3AED),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedLight, size: 18),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 8. COMMUNITY HIGHLIGHT
// ═══════════════════════════════════════════════════════════════════════════
class _CommunityHighlight extends StatelessWidget {
  final bool isLoggedIn;
  const _CommunityHighlight({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0891B2), Color(0xFF0C4A6E)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Diaspora Community',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3)),
                const SizedBox(height: 6),
                const Text(
                  'Share stories, connect with Ugandans across the world, and engage with the community.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => context.go('/community'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0891B2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    child: Text(isLoggedIn ? 'Open Community' : 'Join the Conversation'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.groups_rounded, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color accentColor;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, required this.accentColor, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        if (action != null) ...[
          const Spacer(),
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.darkOrange, fontWeight: FontWeight.w700)),
          ),
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  const _Badge(this.text, this.color, {this.fontSize = 10.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(text,
          style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5)),
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconPill({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

// ── Skeleton loaders ───────────────────────────────────────────────────────
class _NewsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(width: 150, height: 24, borderRadius: 4),
          const SizedBox(height: 14),
          ShimmerLoading(width: double.infinity, height: 272, borderRadius: 22),
          const SizedBox(height: 14),
          Row(
            children: List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ShimmerLoading(width: 198, height: 186, borderRadius: 16),
            )),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(width: 170, height: 24, borderRadius: 4),
          const SizedBox(height: 14),
          Row(
            children: List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ShimmerLoading(width: 180, height: 140, borderRadius: 16),
            )),
          ),
        ],
      ),
    );
  }
}

// ── Error banner ───────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.deepRed.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.deepRed.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.deepRed, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Could not load content. Check your connection.',
                style: TextStyle(fontSize: 13, color: AppColors.deepRed, fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: AppColors.deepRed, padding: EdgeInsets.zero),
            child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Helper ─────────────────────────────────────────────────────────────────
SnackBar _snack(String msg) => SnackBar(
  content: Text(msg),
  backgroundColor: AppColors.primaryBlack,
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  margin: const EdgeInsets.all(16),
  duration: const Duration(seconds: 2),
);
