import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _articles  = [];
  List<dynamic> _categories = [];
  bool _loading     = true;
  bool _loadingMore = false;
  bool _showSearch  = false;
  String? _selectedCategory;
  int _page     = 1;
  bool _hasMore = true;

  final _scrollCtrl  = ScrollController();
  final _searchCtrl  = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiClient.instance.getNews(
            page: 1, category: _selectedCategory, limit: 20),
        ApiClient.instance.getNewsCategories(),
      ]);
      if (mounted) {
        final data = results[0] as Map;
        setState(() {
          _articles   = data['data'] ?? [];
          _categories = results[1] as List;
          _page       = 1;
          _hasMore    = _articles.length < (data['total'] ?? 0);
          _loading    = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final data = await ApiClient.instance
          .getNews(page: _page + 1, category: _selectedCategory, limit: 20);
      if (mounted) {
        final more = data['data'] ?? [];
        setState(() {
          _articles.addAll(more);
          _page++;
          _hasMore = _articles.length < (data['total'] ?? 0);
          _loadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    if (_showSearch) {
      Future.delayed(const Duration(milliseconds: 100),
          () => _searchFocus.requestFocus());
    } else {
      _searchCtrl.clear();
      _selectedCategory = null;
      _loadData();
    }
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
            controller: _scrollCtrl,
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
                titleSpacing: 0,
                toolbarHeight: _showSearch ? 120 : 68,
                flexibleSpace: SafeArea(
                  child: Column(
                    children: [
                      // Main bar
                      SizedBox(
                        height: 68,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: const Icon(Icons.arrow_back_rounded,
                                    color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('News',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.3)),
                                    Text('Uganda Diaspora',
                                        style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: _toggleSearch,
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    _showSearch
                                        ? Icons.close_rounded
                                        : Icons.search_rounded,
                                    key: ValueKey(_showSearch),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Search bar (animated)
                      if (_showSearch)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchCtrl,
                              focusNode: _searchFocus,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search articles...',
                                hintStyle: const TextStyle(
                                    color: Colors.white38, fontSize: 14),
                                prefixIcon: const Icon(Icons.search_rounded,
                                    color: Colors.white38, size: 19),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: (_) => _loadData(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Category pills ─────────────────────────────────────────
              if (_categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    height: 48,
                    color: AppColors.primaryBlack,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      children: [
                        _CategoryPill('All', null, _selectedCategory, () {
                          setState(() => _selectedCategory = null);
                          _loadData();
                        }),
                        ..._categories.map((c) => _CategoryPill(
                              c['name'] ?? '',
                              c['slug'] ?? c['name'],
                              _selectedCategory,
                              () {
                                setState(() =>
                                    _selectedCategory = c['slug'] ?? c['name']);
                                _loadData();
                              },
                            )),
                      ],
                    ),
                  ),
                ),

              // Orange bottom line
              SliverToBoxAdapter(
                child: Container(
                  height: 2,
                  decoration: const BoxDecoration(
                      gradient: AppColors.orangeGradient),
                ),
              ),

              // ── Content ────────────────────────────────────────────────
              if (_loading)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child:
                            ShimmerLoading(width: double.infinity, height: 280, borderRadius: 20),
                      ),
                      childCount: 4,
                    ),
                  ),
                )
              else if (_articles.isEmpty)
                const SliverFillRemaining(child: _EmptyNews())
              else ...[
                // Featured hero (first article)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: _FeaturedCard(article: _articles.first),
                  ),
                ),

                // Rest of articles
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        if (i == _articles.length - 1) {
                          // Last item is the featured one, skip
                          return const SizedBox.shrink();
                        }
                        return _ArticleCard(article: _articles[i + 1]);
                      },
                      childCount:
                          _articles.length > 1 ? _articles.length - 1 : 0,
                    ),
                  ),
                ),

                // Load more spinner
                if (_loadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: AppColors.darkOrange, strokeWidth: 2.5),
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category pill ──────────────────────────────────────────────────────────
class _CategoryPill extends StatelessWidget {
  final String label;
  final String? value;
  final String? selected;
  final VoidCallback onTap;
  const _CategoryPill(this.label, this.value, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkOrange : Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.darkOrange : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ── Featured hero card ─────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final dynamic article;
  const _FeaturedCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl    = article['imageUrl']    as String?;
    final title       = article['title']       as String? ?? '';
    final category    = article['category']    as String? ?? 'News';
    final publishedAt = article['publishedAt'] as String?;
    final author      = article['authorName']  as String? ?? 'Editorial Team';
    final id          = article['id']          as int?    ?? 0;

    DateTime? dt;
    try { dt = publishedAt != null ? DateTime.parse(publishedAt) : null; } catch (_) {}

    return GestureDetector(
      onTap: () => context.push('/news/$id'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
        child: SizedBox(
          height: 290,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl != null && imageUrl.isNotEmpty
                  ? NetworkImageWidget(
                      imageUrl: imageUrl, borderRadius: 0, fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(
                          gradient: AppColors.heroGradient)),
              // Scrim
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x22000000), Color(0xEE000000)],
                    stops: [0.2, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ArticleBadge('FEATURED', AppColors.deepRed),
                        const Spacer(),
                        _ActionPill(
                          icon: Icons.share_outlined,
                          onTap: () => Share.share(title),
                        ),
                        const SizedBox(width: 6),
                        _ActionPill(
                          icon: Icons.bookmark_border_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const Spacer(),
                    _ArticleBadge(category.toUpperCase(), AppColors.darkOrange),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                          letterSpacing: -0.3),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            color: Colors.white60, size: 13),
                        const SizedBox(width: 4),
                        Text(author,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time_rounded,
                            color: Colors.white60, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          dt != null ? timeago.format(dt) : 'Just now',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                        const Spacer(),
                        const Row(
                          children: [
                            Text('Read',
                                style: TextStyle(
                                    color: AppColors.darkOrange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded,
                                color: AppColors.darkOrange, size: 13),
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

// ── Article card (list style) ──────────────────────────────────────────────
class _ArticleCard extends StatelessWidget {
  final dynamic article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl    = article['imageUrl']    as String?;
    final title       = article['title']       as String? ?? '';
    final category    = article['category']    as String? ?? 'News';
    final publishedAt = article['publishedAt'] as String?;
    final author      = article['authorName']  as String? ?? 'Editorial Team';
    final views       = article['viewCount']   as int?    ?? 0;
    final id          = article['id']          as int?    ?? 0;

    DateTime? dt;
    try { dt = publishedAt != null ? DateTime.parse(publishedAt) : null; } catch (_) {}

    return GestureDetector(
      onTap: () => context.push('/news/$id'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.dividerLight),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (imageUrl != null && imageUrl.isNotEmpty)
              Stack(
                children: [
                  NetworkImageWidget(
                      imageUrl: imageUrl,
                      height: 190,
                      width: double.infinity,
                      borderRadius: 0,
                      fit: BoxFit.cover),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _ArticleBadge(category.toUpperCase(), AppColors.darkOrange),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      children: [
                        _ActionPill(
                            icon: Icons.share_outlined,
                            onTap: () => Share.share(title)),
                        const SizedBox(width: 6),
                        _ActionPill(
                            icon: Icons.bookmark_border_rounded, onTap: () {}),
                      ],
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 6,
                decoration: const BoxDecoration(
                    gradient: AppColors.orangeGradient),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl == null || imageUrl.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ArticleBadge(
                          category.toUpperCase(), AppColors.darkOrange),
                    ),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        letterSpacing: -0.2),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundColor:
                            AppColors.primaryBlack.withOpacity(0.08),
                        child: Text(
                          author.isNotEmpty ? author[0].toUpperCase() : 'E',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlack),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          author,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: AppColors.textMutedLight),
                      const SizedBox(width: 3),
                      Text(
                        dt != null ? timeago.format(dt) : '',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMutedLight),
                      ),
                      if (views > 0) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.visibility_outlined,
                            size: 12, color: AppColors.textMutedLight),
                        const SizedBox(width: 3),
                        Text(
                          '$views',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMutedLight),
                        ),
                      ],
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

// ── Shared small widgets ───────────────────────────────────────────────────
class _ArticleBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _ArticleBadge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5)),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionPill({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }
}

class _EmptyNews extends StatelessWidget {
  const _EmptyNews();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkOrange.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.newspaper_rounded,
                size: 48, color: AppColors.darkOrange),
          ),
          const SizedBox(height: 16),
          const Text('No articles found',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight)),
          const SizedBox(height: 6),
          const Text('Try a different category or search term',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}
