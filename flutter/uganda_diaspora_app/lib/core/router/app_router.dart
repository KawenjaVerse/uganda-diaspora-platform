import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/home/screens/home_screen.dart';
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

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) async {
      if (state.matchedLocation == '/splash') return null;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final isAuth = token != null && token.isNotEmpty;
      final isOnAuthPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isAuth && !isOnAuthPage) return '/login';
      if (isAuth && isOnAuthPage) return '/';
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
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/news',
            builder: (context, state) => const NewsListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => NewsDetailScreen(
                  id: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/embassies',
            builder: (context, state) => const EmbassiesScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => EmbassyDetailScreen(
                  id: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/tourism',
            builder: (context, state) => const TourismScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => TourismDetailScreen(
                  id: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/webinars',
            builder: (context, state) => const WebinarsScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityScreen(),
          ),
          GoRoute(
            path: '/opportunities',
            builder: (context, state) => const OpportunitiesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
        ],
      ),
    ],
  );
}
