import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<dynamic> _posts      = [];
  bool _loading             = false;
  String _currentUserName   = 'You';
  // Track liked post IDs client-side
  final Set<int> _likedPostIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final me = prefs.getString('auth_user');
      if (me != null && me.isNotEmpty) _currentUserName = me;

      final data = await ApiClient.instance.getPosts();
      if (mounted) {
        setState(() {
          _posts = data['data'] ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Like toggle ────────────────────────────────────────────────────────
  Future<void> _toggleLike(int id, int index) async {
    final alreadyLiked = _likedPostIds.contains(id);
    setState(() {
      if (alreadyLiked) {
        _likedPostIds.remove(id);
        _posts[index]['likeCount'] =
            ((_posts[index]['likeCount'] as int? ?? 1) - 1).clamp(0, 999999);
      } else {
        _likedPostIds.add(id);
        _posts[index]['likeCount'] =
            ((_posts[index]['likeCount'] as int? ?? 0) + 1);
      }
    });
    if (!alreadyLiked) {
      try {
        await ApiClient.instance.likePost(id);
      } catch (_) {
        // Revert on failure
        if (mounted) {
          setState(() {
            _likedPostIds.remove(id);
            _posts[index]['likeCount'] =
                ((_posts[index]['likeCount'] as int? ?? 1) - 1).clamp(0, 999999);
          });
        }
      }
    }
  }

  // ── Delete post ────────────────────────────────────────────────────────
  Future<void> _deletePost(int id, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Post',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'This post will be permanently removed. Are you sure?',
            style: TextStyle(color: AppColors.textSecondaryLight)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondaryLight))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient.instance.deletePost(id);
      if (mounted) setState(() => _posts.removeAt(index));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snack('Post deleted', icon: Icons.delete_rounded),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snack('Could not delete post', icon: Icons.error_outline),
        );
      }
    }
  }

  // ── Open create post sheet ─────────────────────────────────────────────
  void _openCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePostSheet(onPosted: _loadData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: RefreshIndicator(
          color: AppColors.darkOrange,
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // ── App Bar ────────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: AppColors.primaryBlack,
                floating: true,
                snap: true,
                elevation: 0,
                leadingWidth: 0,
                leading: const SizedBox.shrink(),
                toolbarHeight: 68,
                flexibleSpace: SafeArea(
                  child: Container(
                    color: AppColors.primaryBlack,
                    padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0891B2).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.groups_rounded,
                              color: Color(0xFF0891B2), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Diaspora Community',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.2)),
                              Text('Share · Connect · Engage',
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                        ),
                        // Compose button
                        GestureDetector(
                          onTap: _openCreatePost,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.darkOrange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.edit_rounded,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 5),
                                Text('Post',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Orange line
              SliverToBoxAdapter(
                child: Container(
                    height: 2,
                    decoration:
                        const BoxDecoration(gradient: AppColors.orangeGradient)),
              ),

              // ── "What's on your mind?" bar ─────────────────────────────
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: _openCreatePost,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              AppColors.primaryBlack.withOpacity(0.08),
                          child: const Icon(Icons.person_rounded,
                              color: AppColors.primaryBlack, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(25),
                              border:
                                  Border.all(color: AppColors.dividerLight),
                            ),
                            child: const Text(
                              "What's on your mind?",
                              style: TextStyle(
                                  color: AppColors.textMutedLight,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _QuickAction(
                          icon: Icons.image_rounded,
                          color: const Color(0xFF16A34A),
                          onTap: _openCreatePost,
                        ),
                        const SizedBox(width: 8),
                        _QuickAction(
                          icon: Icons.videocam_rounded,
                          color: const Color(0xFF7C3AED),
                          onTap: _openCreatePost,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── Posts ──────────────────────────────────────────────────
              if (_loading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const Padding(
                      padding:
                          EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: ShimmerCard(),
                    ),
                    childCount: 4,
                  ),
                )
              else if (_posts.isEmpty)
                const SliverFillRemaining(child: _EmptyCommunity())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _PostCard(
                      post: _posts[i],
                      index: i,
                      isLiked: _likedPostIds.contains(_posts[i]['id']),
                      onLike: () => _toggleLike(_posts[i]['id'], i),
                      onDelete: () => _deletePost(_posts[i]['id'], i),
                    ),
                    childCount: _posts.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// POST CARD
// ═══════════════════════════════════════════════════════════════════════════
class _PostCard extends StatefulWidget {
  final dynamic post;
  final int index;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onDelete;

  const _PostCard({
    required this.post,
    required this.index,
    required this.isLiked,
    required this.onLike,
    required this.onDelete,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard>
    with SingleTickerProviderStateMixin {
  bool _showComments   = false;
  List<dynamic> _comments = [];
  bool _loadingComments = false;
  final _commentCtrl  = TextEditingController();
  bool _postingComment = false;

  late final AnimationController _likeCtrl;
  late final Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _likeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _likeScale = Tween<double>(begin: 1.0, end: 1.35)
        .animate(CurvedAnimation(parent: _likeCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _likeCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _loadingComments = true);
    try {
      final list = await ApiClient.instance
          .getComments(widget.post['id'] as int);
      if (mounted) setState(() { _comments = list; _loadingComments = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingComments = false);
    }
  }

  void _toggleComments() {
    setState(() => _showComments = !_showComments);
    if (_showComments && _comments.isEmpty) _loadComments();
  }

  Future<void> _addComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _postingComment = true);
    try {
      await ApiClient.instance
          .createComment(widget.post['id'] as int, text);
      _commentCtrl.clear();
      await _loadComments();
    } catch (_) {} finally {
      if (mounted) setState(() => _postingComment = false);
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await ApiClient.instance
          .deleteComment(widget.post['id'] as int, commentId);
      setState(() => _comments.removeWhere((c) => c['id'] == commentId));
    } catch (_) {}
  }

  void _onLikeTap() {
    widget.onLike();
    _likeCtrl.forward().then((_) => _likeCtrl.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final post        = widget.post;
    final authorName  = post['authorName']    as String? ?? 'Community Member';
    final content     = post['content']       as String? ?? '';
    final imageUrl    = post['imageUrl']      as String?;
    final likeCount   = post['likeCount']     as int?    ?? 0;
    final commentCount= post['commentCount']  as int?    ?? 0;
    final createdAt   = post['createdAt']     as String?;

    DateTime? dt;
    try {
      dt = createdAt != null ? DateTime.parse(createdAt) : null;
    } catch (_) {}

    final initials = authorName.isNotEmpty
        ? authorName.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase()
        : 'CM';

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryBlack.withOpacity(0.08),
                  child: Text(initials,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlack)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authorName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 14)),
                      if (dt != null)
                        Text(timeago.format(dt),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMutedLight)),
                    ],
                  ),
                ),
                // Three-dot menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded,
                      color: AppColors.textSecondaryLight),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              color: AppColors.deepRed, size: 18),
                          SizedBox(width: 10),
                          Text('Delete Post',
                              style: TextStyle(
                                  color: AppColors.deepRed,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined,
                              color: AppColors.textSecondaryLight, size: 18),
                          SizedBox(width: 10),
                          Text('Report',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (v) {
                    if (v == 'delete') widget.onDelete();
                  },
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────────
          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(content,
                  style: const TextStyle(fontSize: 14.5, height: 1.55)),
            ),

          // ── Image ─────────────────────────────────────────────────────
          if (imageUrl != null && imageUrl.isNotEmpty)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 320),
              margin: const EdgeInsets.only(bottom: 12),
              child: NetworkImageWidget(
                  imageUrl: imageUrl,
                  borderRadius: 0,
                  width: double.infinity,
                  fit: BoxFit.cover),
            ),

          // ── Action bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                // Like button
                _ActionBtn(
                  icon: widget.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: widget.isLiked
                      ? AppColors.deepRed
                      : AppColors.textSecondaryLight,
                  label: '$likeCount',
                  scale: _likeScale,
                  onTap: _onLikeTap,
                ),
                const SizedBox(width: 4),
                // Comment button
                _ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: _showComments
                      ? const Color(0xFF0891B2)
                      : AppColors.textSecondaryLight,
                  label: '$commentCount',
                  onTap: _toggleComments,
                ),
                const SizedBox(width: 4),
                // Share button
                _ActionBtn(
                  icon: Icons.share_outlined,
                  iconColor: AppColors.textSecondaryLight,
                  label: 'Share',
                  onTap: () => Share.share(content),
                ),
              ],
            ),
          ),

          // ── Comments section ──────────────────────────────────────────
          if (_showComments) ...[
            Container(
              color: const Color(0xFFF9FAFB),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Comment input
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFF3F4F6),
                        child: Icon(Icons.person_rounded,
                            color: AppColors.primaryBlack, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.dividerLight),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Write a comment...',
                                    hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textMutedLight),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) => _addComment(),
                                ),
                              ),
                              GestureDetector(
                                onTap: _postingComment ? null : _addComment,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _postingComment
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.darkOrange))
                                      : const Icon(Icons.send_rounded,
                                          color: AppColors.darkOrange,
                                          size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (_loadingComments)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.darkOrange),
                        ),
                      ),
                    )
                  else
                    ..._comments.map((c) => _CommentRow(
                          comment: c,
                          onDelete: () => _deleteComment(c['id'] as int),
                        )),

                  if (_comments.isEmpty && !_loadingComments)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No comments yet. Be the first!',
                          style: TextStyle(
                              color: AppColors.textMutedLight,
                              fontSize: 12)),
                    ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],

          // Divider
          const Divider(height: 0, thickness: 0.5, color: AppColors.dividerLight),
        ],
      ),
    );
  }
}

// ── Action button ──────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Animation<double>? scale;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.scale,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(icon, color: iconColor, size: 21);
    if (scale != null) {
      iconWidget = ScaleTransition(scale: scale!, child: iconWidget);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor == AppColors.textSecondaryLight
                        ? AppColors.textSecondaryLight
                        : iconColor)),
          ],
        ),
      ),
    );
  }
}

// ── Comment row ────────────────────────────────────────────────────────────
class _CommentRow extends StatelessWidget {
  final dynamic comment;
  final VoidCallback onDelete;
  const _CommentRow({required this.comment, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final author    = comment['authorName'] as String? ?? 'Member';
    final content   = comment['content']   as String? ?? '';
    final createdAt = comment['createdAt'] as String?;

    DateTime? dt;
    try { dt = createdAt != null ? DateTime.parse(createdAt) : null; } catch (_) {}

    final initials = author.isNotEmpty
        ? author.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase()
        : 'CM';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primaryBlack.withOpacity(0.06),
            child: Text(initials,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlack)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.dividerLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(author,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      if (dt != null)
                        Text(timeago.format(dt),
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMutedLight)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(content,
                      style:
                          const TextStyle(fontSize: 12.5, height: 1.4)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded,
                  size: 14, color: AppColors.textMutedLight),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick action icon ──────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CREATE POST BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════
class _CreatePostSheet extends StatefulWidget {
  final VoidCallback onPosted;
  const _CreatePostSheet({required this.onPosted});

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _contentCtrl  = TextEditingController();
  final _imageCtrl    = TextEditingController();
  bool _posting       = false;
  bool _showImageUrl  = false;
  bool _showVideoUrl  = false;
  String _previewUrl  = '';

  @override
  void dispose() {
    _contentCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snack('Write something before posting', icon: Icons.edit_rounded),
      );
      return;
    }
    setState(() => _posting = true);
    try {
      final imageUrl = _imageCtrl.text.trim().isNotEmpty
          ? _imageCtrl.text.trim()
          : null;
      await ApiClient.instance.createPost(content, imageUrl: imageUrl);
      if (mounted) {
        Navigator.pop(context);
        widget.onPosted();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snack('Failed to post. Try again.', icon: Icons.error_outline),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFF3F4F6),
                  child:
                      Icon(Icons.person_rounded, color: AppColors.primaryBlack, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Community Member',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 14)),
                      Text('Sharing with the Diaspora',
                          style: TextStyle(
                              color: AppColors.textMutedLight, fontSize: 11)),
                    ],
                  ),
                ),
                // Post button
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: _posting ? null : _post,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlack,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    child: _posting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Post'),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 0, thickness: 0.5, color: AppColors.dividerLight),

          // Text input
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _contentCtrl,
              maxLines: null,
              autofocus: true,
              style: const TextStyle(fontSize: 15, height: 1.55),
              decoration: const InputDecoration(
                hintText:
                    "What's on your mind? Share news, stories, questions...",
                hintStyle:
                    TextStyle(color: AppColors.textMutedLight, fontSize: 15),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),

          // Image URL preview
          if (_showImageUrl) ...[
            const Divider(height: 0, thickness: 0.5, color: AppColors.dividerLight),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.image_rounded,
                          color: Color(0xFF16A34A), size: 18),
                      const SizedBox(width: 6),
                      const Text('Photo URL',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() {
                          _showImageUrl = false;
                          _imageCtrl.clear();
                          _previewUrl = '';
                        }),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: AppColors.textMutedLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _imageCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Paste image URL (https://...)',
                      hintStyle: const TextStyle(
                          color: AppColors.textMutedLight, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onChanged: (v) {
                      if (v.startsWith('http')) {
                        setState(() => _previewUrl = v);
                      }
                    },
                  ),
                  if (_previewUrl.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: NetworkImageWidget(
                        imageUrl: _previewUrl,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        borderRadius: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],

          // Bottom action bar
          const Divider(height: 0, thickness: 0.5, color: AppColors.dividerLight),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                const Text('Add to post',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.textSecondaryLight)),
                const SizedBox(width: 12),
                // Photo
                _AttachBtn(
                  icon: Icons.image_rounded,
                  color: const Color(0xFF16A34A),
                  label: 'Photo',
                  active: _showImageUrl,
                  onTap: () => setState(() {
                    _showImageUrl = !_showImageUrl;
                    _showVideoUrl = false;
                  }),
                ),
                const SizedBox(width: 8),
                // Video
                _AttachBtn(
                  icon: Icons.videocam_rounded,
                  color: const Color(0xFF7C3AED),
                  label: 'Video',
                  active: _showVideoUrl,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      _snack('Video URL posting: paste the URL as text in your post',
                          icon: Icons.info_outline),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _AttachBtn(
                  icon: Icons.tag_rounded,
                  color: AppColors.darkOrange,
                  label: 'Hashtag',
                  onTap: () {
                    _contentCtrl.text += ' #';
                    _contentCtrl.selection = TextSelection.fromPosition(
                        TextPosition(offset: _contentCtrl.text.length));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _AttachBtn({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.12) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: active ? color.withOpacity(0.4) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? color : AppColors.textSecondaryLight)),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────
class _EmptyCommunity extends StatelessWidget {
  const _EmptyCommunity();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF0891B2).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.groups_rounded,
                size: 52, color: Color(0xFF0891B2)),
          ),
          const SizedBox(height: 18),
          const Text('No posts yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight)),
          const SizedBox(height: 8),
          const Text('Be the first to share something with the community!',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Snackbar helper ────────────────────────────────────────────────────────
SnackBar _snack(String msg, {IconData icon = Icons.check_circle_rounded}) {
  return SnackBar(
    content: Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    ),
    backgroundColor: AppColors.primaryBlack,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 2),
  );
}
