import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_1_puzzle/data/models/home/carousel_item_data_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:project_1_puzzle/data/models/home/menu_action_type.dart';
import 'package:project_1_puzzle/presentation/pages/home/widgets/carousel_card.dart';
import 'package:project_1_puzzle/presentation/pages/home/widgets/menu.dart';
import 'package:project_1_puzzle/presentation/widgets/overlay.dart';

class Home extends StatefulWidget {
  final List<CarouselItemData> items = [
    CarouselItemData(
      "Modo Tradicional",
      Icons.send_time_extension_sharp,
      "/game/traditional",
    ),
    CarouselItemData("Modo Contrarreloj", Icons.timer_sharp, "/game/timer"),
    CarouselItemData("Modo Zen", Icons.spa, "/game/zen"),
  ];

  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _menuController;
  late AnimationController _overlayController;

  bool _isMenuVisible = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isMenuVisible) {
      _hideMenu();
    } else {
      _showMenu();
    }
  }

  void _showMenu() {
    setState(() {
      _isMenuVisible = true;
    });
    _overlayController.forward();
    _menuController.forward();
  }

  void _hideMenu() {
    _menuController.reverse().then((_) {
      _overlayController.reverse().then((_) {
        setState(() {
          _isMenuVisible = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Puzzle",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: CarouselSlider.builder(
                          itemCount: widget.items.length,
                          options: CarouselOptions(
                            height: 200,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            viewportFraction: 0.8,
                            initialPage: 0,
                            autoPlay: false,
                            scrollPhysics: const BouncingScrollPhysics(),
                          ),
                          itemBuilder: (context, index, realIndex) {
                            final item = widget.items[index];
                            return CarouselCard(item: item);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: AnimatedBuilder(
                        animation: _menuController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _menuController.value * 0.5,
                            child: IconButton(
                              icon: Icon(
                                _isMenuVisible ? Icons.close : Icons.settings,
                                size: 32,
                              ),
                              onPressed: _toggleMenu,
                              tooltip: _isMenuVisible
                                  ? "Cerrar"
                                  : "Configuración",
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isMenuVisible)
              AnimatedOverlay(controller: _overlayController, onTap: _hideMenu),
            if (_isMenuVisible)
              SlidingMenu(
                controller: _menuController,
                onMenuItemTap: (action) {
                  switch (action.type) {
                    case MenuActionType.route:
                      _hideMenu();
                      GoRouter.of(context).push(action.route!);
                      break;
                    case MenuActionType.function:
                      action.function!();
                      _hideMenu();
                      break;
                    case MenuActionType.toggle:
                      action.onToggle!();
                      break;
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
