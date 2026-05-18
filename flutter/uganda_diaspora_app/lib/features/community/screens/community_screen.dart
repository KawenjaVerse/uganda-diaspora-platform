import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<dynamic> _posts = [];
  bool _loading = true;
  final _postController = TextEditingController();
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient.instance.getPosts();
      if (mounted) setState(() { _posts = data['data'] ?? []; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) return;
    setState(() => _posting = true);
    try {
      await ApiClient.instance.createPost(content);
      _postController.clear();
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create post'), behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _likePost(int id, int index) async {
    try {
      await ApiClient.instance.likePost(id);
      if (mounted) {
        setState(() => _posts[index]['likeCount'] = (_posts[index]['likeCount'] ?? 0) + 1);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: Column(
        children: [
          _buildPostComposer(),
          Expanded(
            child: _loading
                ? ListView.builder(padding: const EdgeInsets.all(16), itemCount: 4,
                    itemBuilder: (_, __) => const Padding(padding: EdgeInsets.only(bottom: 16), child: ShimmerCard()))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _posts.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textSecondaryLight),
                                SizedBox(height: 12),
                                Text('No posts yet', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 16)),
                                SizedBox(height: 4),
                                Text('Be the first to share something!', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _posts.length,
                            itemBuilder: (_, i) => _buildPostCard(_posts[i], i),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 18, backgroundColor: AppColors.primary, child: Icon(Icons.person_rounded, color: Colors.white, size: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: const InputDecoration(hintText: 'Share something with the community...', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
              maxLines: null,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _posting ? null : _createPost,
            icon: _posting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map post, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: post['authorAvatarUrl'] != null ? NetworkImage(post['authorAvatarUrl']) : null,
                child: post['authorAvatarUrl'] == null ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 16) : null,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['authorName'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(post['content'] ?? '', style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => _likePost(post['id'], index),
                child: Row(children: [
                  Icon(Icons.favorite_border_rounded, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Text('${post['likeCount'] ?? 0}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                ]),
              ),
              const SizedBox(width: 20),
              Row(children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text('${post['commentCount'] ?? 0}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
