import 'package:go_router/go_router.dart';
import 'package:project_1_puzzle/presentation/pages/home/home.dart';
import 'package:project_1_puzzle/presentation/pages/splash/splash.dart';

import 'route_names.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: "splash",
        builder: (context, state) => const Splash(),
      ),
      GoRoute(
        path: RouteNames.home,
        name: "home",
        builder: (context, state) => const Home(),
      ),
    ],
  );
  static GoRouter get router => _router;
}
