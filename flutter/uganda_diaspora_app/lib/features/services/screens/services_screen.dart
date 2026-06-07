import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: AppColors.primaryBlack,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 18, right: 20),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Our Services', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
                  SizedBox(height: 2),
                  Text('Empowering Uganda\'s Global Diaspora', style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w400)),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _DotPainter())),
                    Positioned(
                      right: -50, top: -50,
                      child: Container(
                        width: 220, height: 220,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkOrange.withOpacity(0.08)),
                      ),
                    ),
                    Positioned(
                      left: -30, bottom: 0,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.deepRed.withOpacity(0.06)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text('7 services available', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _ServiceCard(service: _services[i]),
              childCount: _services.length,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryBlack, Color(0xFF1C0A00)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Need Assistance?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                          SizedBox(height: 4),
                          Text('Our team is ready to help you navigate our services.', style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/contact'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Contact Us'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

const _services = [
  _ServiceData(
    icon: Icons.business_center_rounded,
    color: Color(0xFFD97706),
    title: 'Business Advisory',
    desc: 'Expert business guidance for diaspora entrepreneurs and investors looking to establish or grow ventures in Uganda.',
    tag: 'Advisory',
  ),
  _ServiceData(
    icon: Icons.link_rounded,
    color: Color(0xFF2563EB),
    title: 'Matching & Linking Diaspora',
    desc: 'Connecting diaspora professionals and investors with local partners, institutions, and high-impact opportunities in Uganda.',
    tag: 'Networking',
  ),
  _ServiceData(
    icon: Icons.trending_up_rounded,
    color: Color(0xFF16A34A),
    title: 'Trade & Investment Facilitation',
    desc: 'Streamlining processes for diaspora-led trade deals and investment projects between Uganda and host countries.',
    tag: 'Investment',
  ),
  _ServiceData(
    icon: Icons.supervisor_account_rounded,
    color: Color(0xFF7C3AED),
    title: 'Overseeing Diaspora Lead',
    desc: 'Coordinating and supervising diaspora-led development projects to ensure alignment with Uganda\'s national development goals.',
    tag: 'Coordination',
  ),
  _ServiceData(
    icon: Icons.home_work_rounded,
    color: Color(0xFFB91C1C),
    title: 'Return Migrants Advisory',
    desc: 'Supporting Ugandans who wish to return home with resettlement guidance, career transition, and reintegration programmes.',
    tag: 'Reintegration',
  ),
  _ServiceData(
    icon: Icons.campaign_rounded,
    color: Color(0xFF0891B2),
    title: 'Lobbying & Advocacy',
    desc: 'Representing the interests of the Ugandan diaspora at both local and international levels for effective policy influence.',
    tag: 'Advocacy',
  ),
  _ServiceData(
    icon: Icons.storage_rounded,
    color: Color(0xFF059669),
    title: 'Diaspora Database',
    desc: 'A comprehensive registry of Ugandan diaspora members worldwide to facilitate targeted engagement and service delivery.',
    tag: 'Registry',
  ),
];

class _ServiceData {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final String tag;
  const _ServiceData({required this.icon, required this.color, required this.title, required this.desc, required this.tag});
}

class _ServiceCard extends StatelessWidget {
  final _ServiceData service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go('/contact'),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: service.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(service.icon, color: service.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(service.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryBlack)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: service.color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(service.tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: service.color)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(service.desc, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight, height: 1.55)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Enquire', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: service.color)),
                          const SizedBox(width: 3),
                          Icon(Icons.arrow_forward_rounded, size: 11, color: service.color),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.04);
    for (double x = 0; x < size.width; x += 24) {
      for (double y = 0; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
