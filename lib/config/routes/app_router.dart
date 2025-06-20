import 'package:go_router/go_router.dart';
import 'package:project_1_puzzle/presentation/pages/game/game.dart';
import 'package:project_1_puzzle/presentation/pages/home/home.dart';
import 'package:project_1_puzzle/presentation/pages/splash/splash.dart';
import 'package:flutter/material.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: "splash",
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const Splash()),
      ),
      GoRoute(
        path: RouteNames.home,
        name: "home",
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, Home()),
      ),
      GoRoute(
        path: RouteNames.game,
        name: "game",
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return _buildPageWithTransition(
            context,
            state,
            Game(
              imagePieces: extra['imagePieces'],
              pattern: extra['pattern'],
              difficulty: extra['difficulty'],
              gameMode: extra['gameMode'],
              puzzles: List<String>.from(extra['puzzles']),
            ),
          );
        },
      ),
    ],
  );
  static GoRouter get router => _router;
  static Page<dynamic> _buildPageWithTransition(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);
        var fadeAnimation = animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }
}
