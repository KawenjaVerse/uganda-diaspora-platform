import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StatehouseMessageScreen extends StatelessWidget {
  const StatehouseMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Uganda flag stripes background
                  Column(
                    children: [
                      Expanded(child: Container(color: Colors.black)),
                      Expanded(child: Container(color: AppColors.ugandaYellow)),
                      Expanded(child: Container(color: AppColors.ugandaRed)),
                      Expanded(child: Container(color: Colors.black)),
                      Expanded(child: Container(color: AppColors.ugandaYellow)),
                      Expanded(child: Container(color: AppColors.ugandaRed)),
                    ],
                  ),
                  // Dark overlay
                  Container(color: Colors.black.withOpacity(0.65)),
                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.ugandaYellow,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'OFFICIAL STATEMENT',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Message from the\nStatehouse',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // Official card
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.ugandaYellow.withOpacity(0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black, Colors.grey.shade900],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        child: Row(
                          children: [
                            // Avatar placeholder
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.ugandaYellow, width: 2),
                                color: Colors.grey.shade800,
                              ),
                              child: const Icon(Icons.person_rounded, color: Colors.white70, size: 36),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'H.E. Ambassador Sarah Chelangat',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Head of Diaspora Affairs',
                                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.ugandaYellow, shape: BoxShape.circle)),
                                      const SizedBox(width: 5),
                                      const Text('State House, Kampala', style: TextStyle(color: AppColors.ugandaYellow, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Message content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 6),
                                Text('May 2026', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Dear Ugandan Diaspora,',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            ..._paragraphs.map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Text(
                                p,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  color: Color(0xFF374151),
                                  height: 1.7,
                                ),
                              ),
                            )),

                            const Divider(height: 32),

                            // Signature
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'H.E. Ambassador Sarah Chelangat',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Head of Diaspora Affairs\nState House, Kampala, Uganda',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.5),
                                      ),
                                    ],
                                  ),
                                ),
                                // Uganda coat of arms mini badge
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.ugandaYellow, width: 2),
                                  ),
                                  child: ClipOval(
                                    child: Column(
                                      children: [
                                        Expanded(child: Container(color: Colors.black)),
                                        Expanded(child: Container(color: AppColors.ugandaYellow)),
                                        Expanded(child: Container(color: AppColors.ugandaRed)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Key highlights section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('Key Diaspora Priorities 2026'),
                      const SizedBox(height: 12),
                      ..._priorities.map((p) => _PriorityTile(icon: p.$1, title: p.$2, subtitle: p.$3, color: p.$4)),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.ugandaRed, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }

  static const _paragraphs = [
    'It is my honour and privilege to address the over 3 million Ugandans who call countries across the world their home. You are a vital part of Uganda\'s story — your skills, investments, and unwavering love for our nation are central to achieving Uganda\'s Vision 2040.',
    'In 2025, diaspora remittances reached a historic \$1.2 billion, a testament to your continued commitment to developing our beloved country. The Government of Uganda recognises this immense contribution and is taking concrete steps to deepen engagement with you.',
    'This year, we are launching the Uganda Diaspora Investment Framework — a structured programme to channel diaspora capital into priority sectors including agriculture, technology, real estate, and manufacturing. We are also working to streamline passport and consular services at all our 54 missions worldwide.',
    'I encourage every Ugandan abroad to register on this platform, participate in our investment forums, and take advantage of the scholarships and opportunities we have made available. Together, we shall transform Uganda into a prosperous, modern economy by 2040.',
    'Pearl of Africa — always in our hearts.',
  ];

  static const _priorities = [
    (Icons.attach_money_rounded, 'Diaspora Investment', 'Structured framework for channelling remittances into Uganda', AppColors.ugandaYellow),
    (Icons.school_rounded, 'Education Scholarships', 'Fully funded university places for diaspora children at Makerere', AppColors.ugandaRed),
    (Icons.badge_rounded, 'Diaspora Registration', 'Official registry for all Ugandans living abroad', Colors.black),
    (Icons.location_city_rounded, 'Improved Consular Services', 'Faster passport & visa processing at all 54 missions worldwide', Color(0xFF1B4B91)),
  ];
}

class _PriorityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _PriorityTile({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
