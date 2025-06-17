import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_1_puzzle/config/routes/route_names.dart';
import 'package:project_1_puzzle/presentation/pages/splash/widgets/animated_panel.dart';
import 'package:project_1_puzzle/presentation/pages/splash/widgets/title_panel.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final availableHeight = constraints.maxHeight;
              return GestureDetector(
                onTap: () {
                  GoRouter.of(context).push(RouteNames.home);
                },
                child: Column(
                  children: [
                    AnimatedColorPanel(
                      height: availableHeight * 0.7,
                      width: availableWidth,
                      duration: Duration(seconds: 2),
                    ),
                    TitlePanel(
                      title: "Puzzle",
                      nameAuthor: "Edward Gomez",
                      version: "0.0.1",
                      height: availableHeight * 0.3,
                      width: availableWidth,
                      duration: Duration(seconds: 2),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
