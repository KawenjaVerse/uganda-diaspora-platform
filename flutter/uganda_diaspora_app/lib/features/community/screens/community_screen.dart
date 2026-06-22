import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

// ── Helpers ───────────────────────────────────────────────────────────────

String _initials(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return parts[0][0].toUpperCase();
}

const List<Color> _avatarPalette = [
  Color(0xFFD97706),
  Color(0xFF2563EB),
  Color(0xFF7C3AED),
  Color(0xFF16A34A),
  Color(0xFFB91C1C),
  Color(0xFF0891B2),
];

Color _avatarColor(String initials) {
  if (initials.isEmpty) return _avatarPalette[0];
  return _avatarPalette[initials.codeUnitAt(0) % _avatarPalette.length];
}

// ── User Avatar Widget ────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;

  const _UserAvatar({this.imageUrl, required this.name, this.radius = 22});

  String get _ini => _initials(name);
  Color get _color => _avatarColor(_ini);

  @override
  Widget build(BuildContext context) {
    final hasImg = imageUrl != null && imageUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: _color.withOpacity(0.15),
      child: hasImg ? _imgChild : _textChild,
    );
  }

  Widget get _textChild => Text(
    _ini,
    style: TextStyle(fontSize: radius * 0.55, fontWeight: FontWeight.w800, color: _color),
  );

  Widget get _imgChild {
    final url = imageUrl!;
    if (url.startsWith('data:')) {
      try {
        final idx = url.indexOf(',');
        if (idx == -1) return _textChild;
        final bytes = base64Decode(url.substring(idx + 1));
        return ClipOval(
          child: Image.memory(bytes,
            width: radius * 2, height: radius * 2, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _textChild,
          ),
        );
      } catch (_) { return _textChild; }
    }
    return ClipOval(
      child: Image.network(url,
        width: radius * 2, height: radius * 2, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _textChild,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COMMUNITY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<dynamic> _posts = [];
  bool _loading = false;
  Map<String, dynamic>? _currentUser;
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
      final userJson = prefs.getString('auth_user');
      if (userJson != null && userJson.isNotEmpty) {
        try {
          _currentUser = Map<String, dynamic>.from(jsonDecode(userJson));
        } catch (_) {}
      }
      final data = await ApiClient.instance.getPosts();
      if (mounted) {
        setState(() { _posts = data['data'] ?? []; _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleLike(int id, int index) async {
    final alreadyLiked = _likedPostIds.contains(id);
    setState(() {
      if (alreadyLiked) {
        _likedPostIds.remove(id);
        _posts[index]['likeCount'] = ((_posts[index]['likeCount'] as int? ?? 1) - 1).clamp(0, 999999);
      } else {
        _likedPostIds.add(id);
        _posts[index]['likeCount'] = ((_posts[index]['likeCount'] as int? ?? 0) + 1);
      }
    });
    if (!alreadyLiked) {
      try {
        await ApiClient.instance.likePost(id);
      } catch (_) {
        if (mounted) {
          setState(() {
            _likedPostIds.remove(id);
            _posts[index]['likeCount'] = ((_posts[index]['likeCount'] as int? ?? 1) - 1).clamp(0, 999999);
          });
        }
      }
    }
  }

  Future<void> _deletePost(int id, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Post', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('This post will be permanently removed. Are you sure?',
            style: TextStyle(color: AppColors.textSecondaryLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepRed, foregroundColor: Colors.white,
              elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(_snack('Post deleted', icon: Icons.delete_rounded));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(_snack('Could not delete post', icon: Icons.error_outline));
    }
  }

  void _openCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePostSheet(onPosted: _loadData, currentUser: _currentUser),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = (_currentUser?['fullName'] as String?) ?? 'You';
    final userAvatar = _currentUser?['avatarUrl'] as String?;

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
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(color: const Color(0xFF0891B2).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.groups_rounded, color: Color(0xFF0891B2), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Diaspora Community', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.2)),
                              Text('Share · Connect · Engage', style: TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _openCreatePost,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(color: AppColors.darkOrange, borderRadius: BorderRadius.circular(10)),
                            child: const Row(
                              children: [
                                Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 5),
                                Text('Post', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(height: 2, decoration: const BoxDecoration(gradient: AppColors.orangeGradient)),
              ),

              // ── "What's on your mind?" bar ──────────────────────────────
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: _openCreatePost,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: [
                        _UserAvatar(imageUrl: userAvatar, name: userName, radius: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: AppColors.dividerLight),
                            ),
                            child: const Text("What's on your mind?", style: TextStyle(color: AppColors.textMutedLight, fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _QuickAction(icon: Icons.image_rounded, color: const Color(0xFF16A34A), onTap: _openCreatePost),
                        const SizedBox(width: 8),
                        _QuickAction(icon: Icons.videocam_rounded, color: const Color(0xFF7C3AED), onTap: _openCreatePost),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── Posts ────────────────────────────────────────────────
              if (_loading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 8), child: ShimmerCard()),
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

  const _PostCard({required this.post, required this.index, required this.isLiked, required this.onLike, required this.onDelete});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> with SingleTickerProviderStateMixin {
  bool _showComments = false;
  List<dynamic> _comments = [];
  bool _loadingComments = false;
  final _commentCtrl = TextEditingController();
  bool _postingComment = false;
  Map<String, dynamic>? _currentUser;

  late final AnimationController _likeCtrl;
  late final Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _likeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _likeScale = Tween<double>(begin: 1.0, end: 1.35).animate(CurvedAnimation(parent: _likeCtrl, curve: Curves.elasticOut));
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('auth_user');
    if (userJson != null && mounted) {
      try {
        setState(() { _currentUser = Map<String, dynamic>.from(jsonDecode(userJson)); });
      } catch (_) {}
    }
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
      final list = await ApiClient.instance.getComments(widget.post['id'] as int);
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
      await ApiClient.instance.createComment(widget.post['id'] as int, text);
      _commentCtrl.clear();
      await _loadComments();
    } catch (_) {} finally {
      if (mounted) setState(() => _postingComment = false);
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await ApiClient.instance.deleteComment(widget.post['id'] as int, commentId);
      setState(() => _comments.removeWhere((c) => c['id'] == commentId));
    } catch (_) {}
  }

  void _onLikeTap() {
    widget.onLike();
    _likeCtrl.forward().then((_) => _likeCtrl.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final authorName = post['authorName'] as String? ?? 'Community Member';
    final authorAvatarUrl = post['authorAvatarUrl'] as String?;
    final content = post['content'] as String? ?? '';
    final imageUrl = post['imageUrl'] as String?;
    final likeCount = post['likeCount'] as int? ?? 0;
    final commentCount = post['commentCount'] as int? ?? 0;
    final createdAt = post['createdAt'] as String?;
    final isVideoPost = imageUrl != null && imageUrl.startsWith('data:video/');

    DateTime? dt;
    try { dt = createdAt != null ? DateTime.parse(createdAt) : null; } catch (_) {}

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            child: Row(
              children: [
                _UserAvatar(imageUrl: authorAvatarUrl, name: authorName, radius: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authorName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      if (dt != null)
                        Text(timeago.format(dt), style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondaryLight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'delete', child: Row(children: [
                      Icon(Icons.delete_outline_rounded, color: AppColors.deepRed, size: 18),
                      SizedBox(width: 10),
                      Text('Delete Post', style: TextStyle(color: AppColors.deepRed, fontWeight: FontWeight.w600)),
                    ])),
                    const PopupMenuItem(value: 'report', child: Row(children: [
                      Icon(Icons.flag_outlined, color: AppColors.textSecondaryLight, size: 18),
                      SizedBox(width: 10),
                      Text('Report', style: TextStyle(fontWeight: FontWeight.w600)),
                    ])),
                  ],
                  onSelected: (v) { if (v == 'delete') widget.onDelete(); },
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────
          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(content, style: const TextStyle(fontSize: 14.5, height: 1.55)),
            ),

          // ── Media ─────────────────────────────────────────────────
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            if (isVideoPost)
              _VideoPostCard(dataUrl: imageUrl)
            else
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 360),
                margin: const EdgeInsets.only(bottom: 12),
                child: NetworkImageWidget(imageUrl: imageUrl, borderRadius: 0, width: double.infinity, fit: BoxFit.cover),
              ),
          ],

          // ── Action bar ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                _ActionBtn(
                  icon: widget.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  iconColor: widget.isLiked ? AppColors.deepRed : AppColors.textSecondaryLight,
                  label: '$likeCount',
                  scale: _likeScale,
                  onTap: _onLikeTap,
                ),
                const SizedBox(width: 4),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: _showComments ? const Color(0xFF0891B2) : AppColors.textSecondaryLight,
                  label: '$commentCount',
                  onTap: _toggleComments,
                ),
                const SizedBox(width: 4),
                _ActionBtn(
                  icon: Icons.share_outlined,
                  iconColor: AppColors.textSecondaryLight,
                  label: 'Share',
                  onTap: () => Share.share(content),
                ),
              ],
            ),
          ),

          // ── Comments ─────────────────────────────────────────────
          if (_showComments) ...[
            Container(
              color: const Color(0xFFF9FAFB),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _UserAvatar(
                        imageUrl: _currentUser?['avatarUrl'] as String?,
                        name: (_currentUser?['fullName'] as String?) ?? 'You',
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          onSubmitted: (_) => _addComment(),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            hintStyle: const TextStyle(color: AppColors.textMutedLight, fontSize: 13),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.dividerLight)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.dividerLight)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            isDense: true,
                            suffixIcon: IconButton(
                              icon: _postingComment
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.send_rounded, size: 18, color: AppColors.darkOrange),
                              onPressed: _addComment,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_loadingComments)
                    const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                  else ...[
                    ..._comments.map((c) => _CommentRow(comment: c, onDelete: () => _deleteComment(c['id'] as int))),
                    if (_comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text('No comments yet. Be the first!', style: TextStyle(color: AppColors.textMutedLight, fontSize: 13)),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Video post card ─────────────────────────────────────────────────────────

class _VideoPostCard extends StatelessWidget {
  final String dataUrl;
  const _VideoPostCard({required this.dataUrl});

  @override
  Widget build(BuildContext context) {
    final approxBytes = (dataUrl.length * 3) ~/ 4;
    final sizeMB = (approxBytes / 1024 / 1024).toStringAsFixed(1);
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
            child: const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 12),
          const Text('Video', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('$sizeMB MB', style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Action button ───────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Animation<double>? scale;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.iconColor, required this.label, required this.onTap, this.scale});

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(icon, color: iconColor, size: 21);
    if (scale != null) iconWidget = ScaleTransition(scale: scale!, child: iconWidget);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: iconColor == AppColors.textSecondaryLight ? AppColors.textSecondaryLight : iconColor)),
          ],
        ),
      ),
    );
  }
}

// ── Comment row ─────────────────────────────────────────────────────────────

class _CommentRow extends StatelessWidget {
  final dynamic comment;
  final VoidCallback onDelete;
  const _CommentRow({required this.comment, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final author = comment['authorName'] as String? ?? 'Member';
    final authorAvatar = comment['authorAvatarUrl'] as String?;
    final content = comment['content'] as String? ?? '';
    final createdAt = comment['createdAt'] as String?;
    DateTime? dt;
    try { dt = createdAt != null ? DateTime.parse(createdAt) : null; } catch (_) {}

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserAvatar(imageUrl: authorAvatar, name: author, radius: 14),
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
                  Row(children: [
                    Text(author, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    if (dt != null) Text(timeago.format(dt), style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                  ]),
                  const SizedBox(height: 3),
                  Text(content, style: const TextStyle(fontSize: 12.5, height: 1.4)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close_rounded, size: 14, color: AppColors.textMutedLight)),
          ),
        ],
      ),
    );
  }
}

// ── Quick action ────────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
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
  final Map<String, dynamic>? currentUser;
  const _CreatePostSheet({required this.onPosted, this.currentUser});

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _contentCtrl = TextEditingController();
  bool _posting = false;
  Uint8List? _mediaBytes;
  bool _isVideo = false;
  String? _mediaName;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  String get _userName => (widget.currentUser?['fullName'] as String?) ?? 'Community Member';
  String? get _userAvatar => widget.currentUser?['avatarUrl'] as String?;
  String get _userIni => _initials(_userName);

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 1200, maxHeight: 1200);
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      setState(() { _mediaBytes = bytes; _isVideo = false; _mediaName = picked.name; });
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(_snack('Could not access gallery', icon: Icons.error_outline));
    }
  }

  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (bytes.length > 15 * 1024 * 1024) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(_snack('Video too large (max 15 MB). Try a shorter clip.', icon: Icons.warning_amber_rounded));
        return;
      }
      setState(() { _mediaBytes = bytes; _isVideo = true; _mediaName = picked.name; });
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(_snack('Could not access gallery', icon: Icons.error_outline));
    }
  }

  void _clearMedia() => setState(() { _mediaBytes = null; _mediaName = null; });

  Future<void> _post() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty && _mediaBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(_snack('Add text or media before posting', icon: Icons.edit_rounded));
      return;
    }
    setState(() => _posting = true);
    try {
      String? mediaUrl;
      if (_mediaBytes != null) {
        final mimeType = _isVideo ? 'video/mp4' : 'image/jpeg';
        mediaUrl = 'data:$mimeType;base64,${base64Encode(_mediaBytes!)}';
      }
      await ApiClient.instance.createPost(content.isEmpty ? '📷' : content, imageUrl: mediaUrl);
      if (mounted) {
        Navigator.pop(context);
        widget.onPosted();
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(_snack('Failed to post. Try again.', icon: Icons.error_outline));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.dividerLight, borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
            child: Row(
              children: [
                _UserAvatar(imageUrl: _userAvatar, name: _userName, radius: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const Text('Sharing with the Diaspora', style: TextStyle(color: AppColors.textMutedLight, fontSize: 11)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: _posting ? null : _post,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlack, foregroundColor: Colors.white,
                      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    child: _posting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Post'),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 0, thickness: 0.5, color: AppColors.dividerLight),

          // Text input
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _contentCtrl,
              maxLines: null,
              autofocus: _mediaBytes == null,
              style: const TextStyle(fontSize: 15, height: 1.55),
              decoration: const InputDecoration(
                hintText: "What's on your mind? Share news, stories, questions...",
                hintStyle: TextStyle(color: AppColors.textMutedLight, fontSize: 15),
                border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true,
              ),
            ),
          ),

          // Media preview
          if (_mediaBytes != null) ...[
            const Divider(height: 0, thickness: 0.5, color: AppColors.dividerLight),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _isVideo
                        ? Container(
                            height: 130,
                            width: double.infinity,
                            color: Colors.black87,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.videocam_rounded, color: Colors.white60, size: 36),
                                const SizedBox(height: 8),
                                Text(_mediaName ?? 'Video', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                                Text('${(_mediaBytes!.length / 1024 / 1024).toStringAsFixed(1)} MB', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              ],
                            ),
                          )
                        : Image.memory(_mediaBytes!, height: 160, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: _clearMedia,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
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
                const Text('Add to post', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textSecondaryLight)),
                const SizedBox(width: 12),
                _AttachBtn(
                  icon: Icons.image_rounded,
                  color: const Color(0xFF16A34A),
                  label: 'Photo',
                  active: _mediaBytes != null && !_isVideo,
                  onTap: _pickImage,
                ),
                const SizedBox(width: 8),
                _AttachBtn(
                  icon: Icons.videocam_rounded,
                  color: const Color(0xFF7C3AED),
                  label: 'Video',
                  active: _mediaBytes != null && _isVideo,
                  onTap: _pickVideo,
                ),
                const SizedBox(width: 8),
                _AttachBtn(
                  icon: Icons.tag_rounded,
                  color: AppColors.darkOrange,
                  label: 'Hashtag',
                  onTap: () {
                    _contentCtrl.text += ' #';
                    _contentCtrl.selection = TextSelection.fromPosition(TextPosition(offset: _contentCtrl.text.length));
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

  const _AttachBtn({required this.icon, required this.color, required this.label, required this.onTap, this.active = false});

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
          border: Border.all(color: active ? color.withOpacity(0.4) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? color : AppColors.textSecondaryLight)),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

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
            decoration: BoxDecoration(color: const Color(0xFF0891B2).withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.groups_rounded, size: 52, color: Color(0xFF0891B2)),
          ),
          const SizedBox(height: 18),
          const Text('No posts yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight)),
          const SizedBox(height: 8),
          const Text('Be the first to share something with the community!',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Snackbar helper ─────────────────────────────────────────────────────────

SnackBar _snack(String msg, {IconData icon = Icons.check_circle_rounded}) {
  return SnackBar(
    content: Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    ),
    backgroundColor: AppColors.primaryBlack,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  );
}
