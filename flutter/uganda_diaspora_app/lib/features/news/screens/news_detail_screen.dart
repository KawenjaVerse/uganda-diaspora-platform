import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class NewsDetailScreen extends StatefulWidget {
  final int id;
  const NewsDetailScreen({super.key, required this.id});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  Map<String, dynamic>? _article;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.getNewsById(widget.id);
      if (mounted) setState(() { _article = Map<String, dynamic>.from(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _article == null
              ? const Center(child: Text('Article not found'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 260,
                      pinned: true,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                            child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                          ),
                          onPressed: () => Share.share(_article!['title'] ?? ''),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: NetworkImageWidget(
                          imageUrl: _article!['imageUrl'],
                          width: double.infinity,
                          borderRadius: 0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_article!['category'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                child: Text(_article!['category'], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              _article!['title'] ?? '',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const CircleAvatar(radius: 14, backgroundColor: AppColors.primary, child: Icon(Icons.person_rounded, color: Colors.white, size: 16)),
                                const SizedBox(width: 8),
                                Text(_article!['authorName'] ?? 'Editorial Team', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                const Spacer(),
                                Icon(Icons.visibility_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                const SizedBox(width: 4),
                                Text('${_article!['viewCount'] ?? 0} views', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Divider(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            if (_article!['summary'] != null) ...[
                              Text(
                                _article!['summary'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Text(
                              _article!['content'] ?? '',
                              style: const TextStyle(fontSize: 15, height: 1.8),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
