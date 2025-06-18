import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class Game extends StatefulWidget {
  final String pattern;
  final String difficulty;
  final String gameMode;
  final List<String> puzzles;

  const Game({
    super.key,
    required this.pattern,
    required this.difficulty,
    required this.gameMode,
    required this.puzzles,
  });
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with TickerProviderStateMixin {
  int moves = 0;
  Duration timeElapsed = Duration.zero;

  List<String> currentPuzzle = [];
  List<String> solvedPuzzle = [];
  int emptyIndex = 0;
  int gridSize = 3;
  bool isGameStarted = false;
  bool isShuffling = false;
  bool isPuzzleSolved = false;
  bool isFirstTapInGame = false;

  late AnimationController _curtainController;
  late AnimationController _pieceController;
  late Animation<double> _curtainAnimation;
  late Animation<double> _pieceAnimation;

  int? movingPieceIndex;
  Offset? movingPieceOffset;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    gridSize = int.parse(widget.difficulty);
    _curtainController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _pieceController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _curtainAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _curtainController, curve: Curves.easeInOut),
    );
    _pieceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pieceController, curve: Curves.easeOutBack),
    );

    initializePuzzle();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _curtainController.dispose();
    _pieceController.dispose();
    super.dispose();
  }

  void initializePuzzle() {
    gameTimer?.cancel();
    solvedPuzzle = List.from(widget.puzzles);
    while (solvedPuzzle.length < gridSize * gridSize - 1) {
      solvedPuzzle.add((solvedPuzzle.length + 1).toString());
    }
    currentPuzzle = List.from(solvedPuzzle);
    emptyIndex = gridSize * gridSize - 1;
    Future.delayed(Duration(milliseconds: 500), () {
      startIntroAnimation();
    });
  }

  void startIntroAnimation() async {
    setState(() {
      isShuffling = true;
      isGameStarted = false;
      isPuzzleSolved = false;
    });
    await _curtainController.forward();
    shufflePuzzle();
    await _curtainController.reverse();
    setState(() {
      isShuffling = false;
      isGameStarted = true;
    });
    _pieceController.forward();
  }

  void startGameTimer() {
    gameTimer?.cancel();
    timeElapsed = Duration.zero;
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && !isPuzzleSolved) {
        setState(() {
          timeElapsed += Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void shufflePuzzle() {
    Random random = Random();
    List<int> possibleMoves = [];
    int shuffleMoves = 100 + random.nextInt(100);
    for (int i = 0; i < shuffleMoves; i++) {
      possibleMoves = getPossibleMoves();
      if (possibleMoves.isNotEmpty) {
        int moveIndex = possibleMoves[random.nextInt(possibleMoves.length)];
        swapPieces(moveIndex, emptyIndex, animate: false);
      }
    }
    setState(() {});
  }

  List<int> getPossibleMoves() {
    List<int> moves = [];
    int row = emptyIndex ~/ gridSize;
    int col = emptyIndex % gridSize;
    if (row > 0) moves.add(emptyIndex - gridSize);
    if (row < gridSize - 1) moves.add(emptyIndex + gridSize);
    if (col > 0) moves.add(emptyIndex - 1);
    if (col < gridSize - 1) moves.add(emptyIndex + 1);
    return moves;
  }

  void swapPieces(int index1, int index2, {bool animate = true}) {
    String temp = currentPuzzle[index1];
    currentPuzzle[index1] = currentPuzzle[index2];
    currentPuzzle[index2] = temp;
    emptyIndex = index1;
  }

  void swapPiecesAfterSuffling(int index1, int index2) {
    if (isGameStarted && !isPuzzleSolved && !isShuffling) {
      setState(() {
        movingPieceIndex = index1;
        moves++;

        if (!isFirstTapInGame) {
          isFirstTapInGame = true;
          startGameTimer();
        }
      });

      _pieceController.reset();
      _pieceController.forward().then((_) {
        setState(() {
          movingPieceIndex = null;
        });

        swapPieces(index1, index2);
        checkIfSolved();
      });
    }
  }

  void checkIfSolved() {
    bool solved = true;
    for (int i = 0; i < currentPuzzle.length; i++) {
      if (i < solvedPuzzle.length && currentPuzzle[i] != solvedPuzzle[i]) {
        solved = false;
        break;
      }
    }

    if (solved && !isPuzzleSolved) {
      setState(() {
        isPuzzleSolved = true;
      });
      gameTimer?.cancel();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('¡Felicidades!'),
          scrollable: false,
          content: Text('¡Has resuelto el puzzle en $moves movimientos!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text('Jugar de nuevo'),
            ),
          ],
        ),
      );
    }
  }

  void onPieceTap(int index) {
    if (!isGameStarted || isShuffling || isPuzzleSolved) return;

    List<int> possibleMoves = getPossibleMoves();
    if (possibleMoves.contains(index)) {
      swapPiecesAfterSuffling(index, emptyIndex);
    }
  }

  void resetGame() {
    gameTimer?.cancel();

    setState(() {
      moves = 0;
      isFirstTapInGame = false;
      timeElapsed = Duration.zero;
      isGameStarted = false;
      isPuzzleSolved = false;
      movingPieceIndex = null;
    });

    _curtainController.reset();
    _pieceController.reset();
    initializePuzzle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Puzzle - ${widget.pattern}')),
      body: SafeArea(
        child: Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildPuzzlePreview(),
                  Column(
                    children: [
                      Text(
                        'Tiempo: ${timeElapsed.inMinutes}:${(timeElapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: theme.textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Movimientos: $moves',
                        style: theme.textTheme.titleLarge,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Reiniciar juego'),
                              content: Text(
                                '¿Estás seguro de que quieres reiniciar el juego? Se perderán los avances actuales.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    resetGame();
                                  },
                                  child: Text('Reiniciar'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.refresh,
                          size: theme.iconTheme.size,
                          color: theme.iconTheme.color,
                        ),
                        label: Text(
                          'Reiniciar',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              buildPuzzleGame(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPuzzleGame() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 370,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: AnimatedBuilder(
                animation: _pieceAnimation,
                builder: (context, child) {
                  return GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      return buildPuzzlePiece(index);
                    },
                  );
                },
              ),
            ),
            if (isShuffling)
              AnimatedBuilder(
                animation: _curtainAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(
                            alpha: _curtainAnimation.value * 0.9,
                          ),
                          Colors.blue[100]!.withValues(
                            alpha: _curtainAnimation.value * 0.8,
                          ),
                          Colors.white.withValues(
                            alpha: _curtainAnimation.value * 0.9,
                          ),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1500),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.5 + (value * 0.5),
                                child: Opacity(
                                  opacity: _curtainAnimation.value,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.cloud,
                                        size: 80,
                                        color: Colors.blue[300],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        '¡Mezclando!',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget buildPuzzlePiece(int index) {
    bool isEmpty = index == emptyIndex;
    bool isMoving = movingPieceIndex == index;

    return GestureDetector(
      onTap: () => onPieceTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: isMoving ? 300 : 200),
        curve: Curves.easeOutBack,
        transform: Matrix4.identity()
          ..scale(isMoving ? 1.1 : 1.0)
          ..rotateZ(isMoving ? 0.05 : 0.0),
        decoration: BoxDecoration(
          color: isEmpty
              ? Colors.grey[200]
              : (isPuzzleSolved ? Colors.green[100] : Colors.blue[50]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEmpty
                ? Colors.grey[400]!
                : (isPuzzleSolved ? Colors.green[400]! : Colors.blue[300]!),
            width: 2,
          ),
          boxShadow: isEmpty
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: Offset(0, isMoving ? 4 : 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onPieceTap(index),
            child: Center(
              child: isEmpty
                  ? Icon(
                      Icons.crop_free,
                      size: gridSize == 3 ? 20 : (gridSize == 4 ? 16 : 12),
                      color: Colors.grey[400],
                    )
                  : AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: gridSize == 3
                            ? 18
                            : (gridSize == 4 ? 16 : 14),
                        fontWeight: FontWeight.bold,
                        color: isPuzzleSolved
                            ? Colors.green[800]!
                            : Colors.blue[800]!,
                      ),
                      child: Text(
                        index < currentPuzzle.length
                            ? currentPuzzle[index]
                            : '',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPuzzlePreview() {
    List<String> puzzleContent = widget.puzzles;
    int gridSize = widget.difficulty == '3'
        ? 3
        : (widget.difficulty == '4' ? 4 : 5);
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
                  ? Icon(Icons.close, size: 12, color: Colors.grey[600])
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
}
