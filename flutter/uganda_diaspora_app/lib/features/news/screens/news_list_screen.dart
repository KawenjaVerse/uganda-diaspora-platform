import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  List<dynamic> _articles = [];
  List<dynamic> _categories = [];
  bool _loading = true;
  String? _selectedCategory;
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiClient.instance.getNews(page: 1, category: _selectedCategory),
        ApiClient.instance.getNewsCategories(),
      ]);
      if (mounted) {
        final data = results[0] as Map;
        setState(() {
          _articles = data['data'] ?? [];
          _categories = results[1] as List;
          _page = 1;
          _hasMore = (_articles.length < (data['total'] ?? 0));
          _loading = false;
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
      final data = await ApiClient.instance.getNews(page: _page + 1, category: _selectedCategory);
      if (mounted) {
        final newArticles = data['data'] ?? [];
        setState(() {
          _articles.addAll(newArticles);
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: Column(
        children: [
          if (_categories.isNotEmpty) _buildCategoryFilter(),
          Expanded(
            child: _loading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: ShimmerCard(),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _articles.length + (_loadingMore ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == _articles.length) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ));
                        }
                        return _buildArticleCard(_articles[i]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip('All', null),
          ..._categories.map((c) => _buildCategoryChip(c['name'], c['slug'])),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final selected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _selectedCategory = value);
          _loadData();
        },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? Colors.white : null,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildArticleCard(Map article) {
    return GestureDetector(
      onTap: () => context.push('/news/${article['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkImageWidget(imageUrl: article['imageUrl'], height: 180, width: double.infinity, borderRadius: 0),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article['category'] != null)
                    Wrap(
                      spacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(article['category'], style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                        ),
                        if (article['isFeatured'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Featured', style: TextStyle(fontSize: 11, color: AppColors.ugandaBlack, fontWeight: FontWeight.w500)),
                          ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(article['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3)),
                  if (article['summary'] != null) ...[
                    const SizedBox(height: 8),
                    Text(article['summary'], maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), height: 1.4)),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(article['authorName'] ?? 'Editorial Team', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                      const Spacer(),
                      Icon(Icons.visibility_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text('${article['viewCount'] ?? 0}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
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
