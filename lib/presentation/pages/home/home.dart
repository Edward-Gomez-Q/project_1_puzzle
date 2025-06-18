import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_1_puzzle/data/models/home/carousel_item_data_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:project_1_puzzle/data/models/home/menu_action_type.dart';
import 'package:project_1_puzzle/presentation/pages/home/widgets/carousel_card.dart';
import 'package:project_1_puzzle/presentation/pages/home/widgets/menu.dart';
import 'package:project_1_puzzle/presentation/widgets/overlay.dart';

class Home extends StatefulWidget {
  final List<CarouselItemData> itemsPattern = [
    CarouselItemData(
      "Abecedario",
      Icons.text_fields,
      "Juega con las letras del abecedario",
      "ABC",
    ),
    CarouselItemData("Números", Icons.numbers, "Juega con los números", "123"),
    CarouselItemData(
      "Colores",
      Icons.palette,
      "Juega con colores al azar",
      "RGB",
    ),
    CarouselItemData(
      "Formas geométricas",
      Icons.shape_line,
      "Juega con formas geométricas",
      "SHAPES",
    ),
    CarouselItemData("Animales", Icons.pets, "Juega con animales", "ANIMALS"),
  ];

  final List<CarouselItemData> itemsDifficulty = [
    CarouselItemData(
      "Fácil: 3x3",
      Icons.check_circle_outline,
      "Ideal para principiantes",
      "3",
    ),
    CarouselItemData("Medio: 4x4", Icons.shield, "Un desafío moderado", "4"),
    CarouselItemData(
      "Difícil: 5x5",
      Icons.dangerous_rounded,
      "Para jugadores experimentados",
      "5",
    ),
  ];

  final List<CarouselItemData> itemsSort = [
    CarouselItemData(
      "Ordenado",
      Icons.link_outlined,
      "Ordena los elementos de forma ascendente",
      "ASC",
    ),
    CarouselItemData(
      "Reversa",
      Icons.link_off,
      "Ordena los elementos de forma descendente",
      "DESC",
    ),
    CarouselItemData(
      "Aleatorio",
      Icons.shuffle,
      "Ordena los elementos de forma aleatoria",
      "RANDOM",
    ),
  ];

  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  List<String> puzzleContent = [];
  late AnimationController _menuController;
  late AnimationController _overlayController;
  bool _isMenuVisible = false;

  int selectedPatternIndex = 0;
  int selectedDifficultyIndex = 0;
  int selectedSortIndex = 0;
  CarouselItemData? selectedPattern;
  CarouselItemData? selectedDifficulty;
  CarouselItemData? selectedSort;

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
    selectedPattern = widget.itemsPattern.isNotEmpty
        ? widget.itemsPattern[0]
        : null;
    selectedDifficulty = widget.itemsDifficulty.isNotEmpty
        ? widget.itemsDifficulty[0]
        : null;
    selectedSort = widget.itemsSort.isNotEmpty ? widget.itemsSort[0] : null;
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
                        "¡Elige tu modo de juego!",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            carouselBuilder(widget.itemsPattern, "pattern"),
                            const SizedBox(height: 8),
                            carouselBuilder(
                              widget.itemsDifficulty,
                              "difficulty",
                            ),
                            const SizedBox(height: 8),
                            carouselBuilder(widget.itemsSort, "sort"),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Vista previa',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              buildPuzzlePreview(),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed:
                                    selectedPattern != null &&
                                        selectedDifficulty != null
                                    ? () {
                                        startGameWithConfig();
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.play_arrow,
                                  size: Theme.of(context).iconTheme.size,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                label: Text(
                                  '¡Jugar!',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                                size: Theme.of(context).iconTheme.size,
                                color: Theme.of(context).iconTheme.color,
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

  Widget carouselBuilder(List<CarouselItemData> items, String carouselType) {
    return CarouselSlider.builder(
      itemCount: items.length,
      options: CarouselOptions(
        height: 75,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        viewportFraction: 0.8,
        initialPage: 0,
        autoPlay: false,
        scrollPhysics: const BouncingScrollPhysics(),
        onPageChanged: (index, reason) {
          setState(() {
            switch (carouselType) {
              case 'pattern':
                selectedPatternIndex = index;
                selectedPattern = items[index];
                break;
              case 'difficulty':
                selectedDifficultyIndex = index;
                selectedDifficulty = items[index];
                break;
              case 'sort':
                selectedSortIndex = index;
                selectedSort = items[index];
                break;
            }
          });
        },
      ),
      itemBuilder: (context, index, realIndex) {
        final item = items[index];
        return CarouselCard(item: item);
      },
    );
  }

  List<String> generatePuzzleContent(
    int gridSize,
    String pattern,
    String sort,
  ) {
    List<String> content = [];

    switch (pattern) {
      case 'ABC':
        for (int i = 0; i < gridSize * gridSize - 1; i++) {
          content.add(String.fromCharCode(65 + i));
        }
        break;
      case '123':
        for (int i = 1; i < gridSize * gridSize; i++) {
          content.add(i.toString());
        }
        break;
      case 'RGB':
        List<String> colors = [
          '🔴',
          '🟠',
          '🟡',
          '🟢',
          '🔵',
          '🟣',
          '🟤',
          '⚫',
          '⚪',
          '🩷',
          '🩶',
          '🟫',
          '🟨',
          '🟩',
          '🟦',
          '🟪',
        ];
        for (int i = 0; i < gridSize * gridSize - 1; i++) {
          content.add(colors[i % colors.length]);
        }
        break;
      case 'SHAPES':
        List<String> shapes = [
          '○',
          '□',
          '△',
          '◇',
          '☆',
          '♠',
          '♥',
          '♦',
          '♣',
          '⬟',
          '⬢',
          '⬡',
          '◯',
          '◊',
          '▲',
          '■',
        ];
        for (int i = 0; i < gridSize * gridSize - 1; i++) {
          content.add(shapes[i % shapes.length]);
        }
        break;
      case 'ANIMALS':
        List<String> animals = [
          '🐶',
          '🐱',
          '🐭',
          '🐹',
          '🐰',
          '🦊',
          '🐻',
          '🐼',
          '🐨',
          '🐯',
          '🦁',
          '🐮',
          '🐷',
          '🐸',
          '🐵',
          '🐔',
          '🐧',
          '🐦',
          '🐤',
          '🐠',
          '🐟',
          '🐬',
          '🐳',
          '🐊',
          '🐍',
          '🐢',
          '🐙',
        ];
        for (int i = 0; i < gridSize * gridSize - 1; i++) {
          content.add(animals[i % animals.length]);
        }
        break;
      default:
        for (int i = 1; i < gridSize * gridSize; i++) {
          content.add(i.toString());
        }
    }
    if (pattern != '123') {
      if (sort == 'ASC') {
        content.sort();
      } else if (sort == 'DESC') {
        content.sort((a, b) => b.compareTo(a));
      } else if (sort == 'RANDOM') {
        content.shuffle();
      }
    } else {
      if (sort == 'ASC') {
        content.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      } else if (sort == 'DESC') {
        content.sort((a, b) => int.parse(b).compareTo(int.parse(a)));
      } else if (sort == 'RANDOM') {
        content.shuffle();
      }
    }
    return content;
  }

  Widget buildPuzzlePreview() {
    if (selectedPattern == null || selectedDifficulty == null) {
      return Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Selecciona opciones',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    int gridSize = int.parse(selectedDifficulty!.code);
    puzzleContent = generatePuzzleContent(
      gridSize,
      selectedPattern!.code,
      selectedSort?.code ?? 'ASC',
    );

    return SizedBox(
      height: 120,
      width: 120,
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          childAspectRatio: 1.0,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          bool isEmpty = index == gridSize * gridSize - 1;
          return Container(
            decoration: BoxDecoration(
              color: isEmpty ? Colors.grey[300] : Colors.blue[100],
              border: Border.all(
                color: isEmpty ? Colors.grey[400]! : Colors.blue[300]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: isEmpty
                  ? Icon(
                      Icons.close,
                      size: Theme.of(context).iconTheme.size,
                      color: Theme.of(context).iconTheme.color,
                    )
                  : Text(
                      puzzleContent[index],
                      style: TextStyle(
                        fontSize: gridSize == 3
                            ? 14
                            : (gridSize == 4 ? 12 : 10),
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  void startGameWithConfig() {
    if (selectedPattern != null && selectedDifficulty != null) {
      puzzleContent.add('X');
      GoRouter.of(context).push(
        '/game',
        extra: {
          'pattern': selectedPattern!.code,
          'difficulty': selectedDifficulty!.code,
          'gameMode': selectedSort?.code ?? 'ASC',
          'puzzles': puzzleContent,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona todas las opciones')),
      );
    }
  }
}
