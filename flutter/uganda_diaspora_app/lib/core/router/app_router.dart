import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/statehouse_message_screen.dart';
import '../../features/news/screens/news_list_screen.dart';
import '../../features/news/screens/news_detail_screen.dart';
import '../../features/embassies/screens/embassies_screen.dart';
import '../../features/embassies/screens/embassy_detail_screen.dart';
import '../../features/tourism/screens/tourism_screen.dart';
import '../../features/tourism/screens/tourism_detail_screen.dart';
import '../../features/webinars/screens/webinars_screen.dart';
import '../../features/events/screens/events_screen.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/opportunities/screens/opportunities_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Routes that require the user to be signed in.
const _protectedRoutes = ['/community', '/profile', '/notifications'];

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) async {
      // Splash is always allowed
      if (state.matchedLocation == '/splash') return null;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final isAuth = token != null && token.isNotEmpty;

      final isOnAuthPage =
          state.matchedLocation == '/login' || state.matchedLocation == '/register';

      // If accessing a protected route without being logged in → login
      final requiresAuth =
          _protectedRoutes.any((r) => state.matchedLocation.startsWith(r));
      if (!isAuth && requiresAuth) return '/login';

      // Logged-in users visiting auth pages → home
      if (isAuth && isOnAuthPage) return '/';

      // Public routes (home, news, embassies, tourism, webinars, events,
      // opportunities, statehouse) are accessible without login
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Statehouse message — full screen, outside shell
      GoRoute(
        path: '/statehouse',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StatehouseMessageScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: '/news',
            builder: (_, __) => const NewsListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, state) =>
                    NewsDetailScreen(id: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(
            path: '/embassies',
            builder: (_, __) => const EmbassiesScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, state) =>
                    EmbassyDetailScreen(id: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(
            path: '/tourism',
            builder: (_, __) => const TourismScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, state) =>
                    TourismDetailScreen(id: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(path: '/webinars',     builder: (_, __) => const WebinarsScreen()),
          GoRoute(path: '/events',       builder: (_, __) => const EventsScreen()),
          GoRoute(path: '/community',    builder: (_, __) => const CommunityScreen()),
          GoRoute(path: '/opportunities',builder: (_, __) => const OpportunitiesScreen()),
          GoRoute(path: '/profile',      builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/notifications',builder: (_, __) => const NotificationsScreen()),
        ],
      ),
    ],
  );
}
