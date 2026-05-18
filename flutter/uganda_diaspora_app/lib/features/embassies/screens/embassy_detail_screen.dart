import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/network_image_widget.dart';

class EmbassyDetailScreen extends StatefulWidget {
  final int id;
  const EmbassyDetailScreen({super.key, required this.id});

  @override
  State<EmbassyDetailScreen> createState() => _EmbassyDetailScreenState();
}

class _EmbassyDetailScreenState extends State<EmbassyDetailScreen> {
  Map<String, dynamic>? _embassy;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.getEmbassyById(widget.id);
      if (mounted) setState(() { _embassy = Map<String, dynamic>.from(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _embassy == null
              ? const Center(child: Text('Embassy not found'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 220,
                      pinned: true,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text('Uganda Embassy\nin ${_embassy!['country']}', style: const TextStyle(fontSize: 13)),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            NetworkImageWidget(imageUrl: _embassy!['imageUrl'], width: double.infinity, borderRadius: 0, fit: BoxFit.cover),
                            Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black54]))),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_embassy!['ambassadorName'] != null) _buildAmbassadorCard(),
                            const SizedBox(height: 20),
                            _buildInfoSection(),
                            const SizedBox(height: 20),
                            if (_embassy!['servicesOffered'] != null) _buildServices(),
                            const SizedBox(height: 20),
                            _buildActionButtons(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAmbassadorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: _embassy!['ambassadorImageUrl'] != null ? NetworkImage(_embassy!['ambassadorImageUrl']) : null,
            child: _embassy!['ambassadorImageUrl'] == null ? const Icon(Icons.person_rounded, color: Colors.white, size: 28) : null,
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ambassador', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(_embassy!['ambassadorName'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final rows = <(IconData, String, String?)>[
      (Icons.location_on_outlined, 'Address', _embassy!['address']),
      (Icons.phone_outlined, 'Phone', _embassy!['phone']),
      (Icons.email_outlined, 'Email', _embassy!['email']),
      (Icons.access_time_rounded, 'Office Hours', _embassy!['officeHours']),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...rows.where((r) => r.$3 != null).map((r) => _buildInfoRow(r.$1, r.$2, r.$3!)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Services Offered', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Text(_embassy!['servicesOffered'], style: const TextStyle(fontSize: 14, height: 1.6)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (_embassy!['phone'] != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _launch('tel:${_embassy!['phone']}'),
              icon: const Icon(Icons.phone_rounded),
              label: const Text('Call'),
            ),
          ),
        if (_embassy!['phone'] != null && _embassy!['email'] != null) const SizedBox(width: 12),
        if (_embassy!['email'] != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _launch('mailto:${_embassy!['email']}'),
              icon: const Icon(Icons.email_outlined),
              label: const Text('Email'),
            ),
          ),
      ],
    );
  }
}
