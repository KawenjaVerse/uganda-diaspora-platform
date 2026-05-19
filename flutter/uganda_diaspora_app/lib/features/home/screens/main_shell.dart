import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/diaspora_registration_sheet.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/news')) return 1;
    if (location.startsWith('/embassies')) return 2;
    if (location.startsWith('/community')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/news'); break;
      case 2: context.go('/embassies'); break;
      case 3: context.go('/community'); break;
      case 4: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);
    final isHome = location == '/';

    return Scaffold(
      body: child,

      // ── Diaspora Registration FAB (home only) ──────────────────────────────
      floatingActionButton: isHome
          ? FloatingActionButton.extended(
              onPressed: () => showDiasporaRegistrationSheet(context),
              backgroundColor: AppColors.ugandaYellow,
              foregroundColor: Colors.black,
              elevation: 4,
              icon: const Icon(Icons.how_to_reg_rounded, size: 22),
              label: const Text(
                'Diaspora Registration',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.3),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // ── Bottom Navigation ──────────────────────────────────────────────────
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Uganda flag accent strip above nav bar
          Row(
            children: const [
              Expanded(child: SizedBox(height: 2, child: ColoredBox(color: Colors.black))),
              Expanded(child: SizedBox(height: 2, child: ColoredBox(color: AppColors.ugandaYellow))),
              Expanded(child: SizedBox(height: 2, child: ColoredBox(color: AppColors.ugandaRed))),
              Expanded(child: SizedBox(height: 2, child: ColoredBox(color: Colors.black))),
              Expanded(child: SizedBox(height: 2, child: ColoredBox(color: AppColors.ugandaYellow))),
              Expanded(child: SizedBox(height: 2, child: ColoredBox(color: AppColors.ugandaRed))),
            ],
          ),
          BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => _onTap(context, index),
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: const Color(0xFF9CA3AF),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper_outlined),
                activeIcon: Icon(Icons.newspaper_rounded),
                label: 'News',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_city_outlined),
                activeIcon: Icon(Icons.location_city_rounded),
                label: 'Embassies',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline_rounded),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Community',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
