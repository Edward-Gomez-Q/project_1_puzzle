import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:project_1_puzzle/data/models/game/puzzle_solver.dart';
import 'package:project_1_puzzle/data/models/game/solution_result.dart';

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

  bool isGameResolvedBySolver = false;
  bool isSolving = false;
  bool isAnimatingSolution = false;
  SolutionResult? solutionResult;
  List<int> solutionMoves = [];
  int currentSolutionStep = 0;
  Timer? solutionTimer;

  late AnimationController _overlayController;

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
    _overlayController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    initializePuzzle();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _overlayController.dispose();
    _curtainController.dispose();
    _pieceController.dispose();
    solutionTimer?.cancel();
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
        child: Stack(
          children: [
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                            style: theme.textTheme.titleSmall,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Movimientos: $moves',
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  (isSolving || isAnimatingSolution || solutionResult != null)
                      ? Column(
                          children: [SizedBox(height: 2), buildSolverResults()],
                        )
                      : Container(),
                  buildPuzzleGame(),
                  const SizedBox(height: 4),
                  buildOptions(),
                ],
              ),
            ),
            if (isGameResolvedBySolver)
              AnimatedBuilder(
                animation: _overlayController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _overlayController.value,
                    child: Container(
                      color: Colors.black54,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 32,
                          ), // Espacio desde el fondo
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  300, // Opcional, si quieres limitarlo horizontalmente
                            ),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (isSolving) ...[
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text('Resolviendo puzzle...'),
                                      Text('Esto puede tomar unos segundos'),
                                    ] else if (isAnimatingSolution) ...[
                                      Icon(
                                        Icons.auto_fix_high,
                                        size: 32,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(height: 8),
                                      Text('Ejecutando solución automática'),
                                      Text(
                                        'Paso $currentSolutionStep/${solutionMoves.length}',
                                      ),
                                      SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: solutionMoves.isEmpty
                                            ? 0
                                            : currentSolutionStep /
                                                  solutionMoves.length,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
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

  Widget buildOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            GoRouter.of(context).go('/home');
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          icon: Icon(Icons.exit_to_app, size: 10),
          label: Text('Salir', style: Theme.of(context).textTheme.bodySmall),
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
                      setState(() {
                        isGameResolvedBySolver = false;
                        isSolving = false;
                        isAnimatingSolution = false;
                        solutionResult = null;
                        solutionMoves.clear();
                        currentSolutionStep = 0;
                      });
                      _overlayController.reverse();
                      _curtainController.reset();
                      _pieceController.reset();
                    },
                    child: Text('Reiniciar'),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          icon: Icon(Icons.refresh, size: 10),
          label: Text(
            'Reiniciar',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (gridSize <= 4)
          ElevatedButton.icon(
            onPressed: isSolving || isAnimatingSolution
                ? null
                : () {
                    showSolutionDialog();
                  },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            icon: Icon(Icons.flash_on_outlined, size: 10),
            label: Text(
              isSolving ? 'Resolviendo...' : 'Solución',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  void showSolutionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Solución del puzzle'),
        content: Text(
          '¿Estás seguro de que quieres ver la solución del puzzle? Se perderán los avances actuales.',
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
              startSolvingProcess();
            },
            child: Text('Solucionar puzzle'),
          ),
        ],
      ),
    );
  }

  void startSolvingProcess() async {
    setState(() {
      isSolving = true;
      isGameResolvedBySolver = true;
    });
    await _overlayController.forward();
    await solvePuzzleInBackground();
    if (solutionResult != null && solutionResult!.solvable) {
      await startSolutionAnimation();
    } else {
      showSolutionError();
    }
  }

  Future<void> animateSolution(List<int> moves) async {
    for (final move in moves) {
      int tileToMove = move;
      int index = currentPuzzle.indexOf(tileToMove.toString());

      onPieceTap(index); // Esto ya maneja el swap y la animación
      await Future.delayed(const Duration(milliseconds: 300));
    }

    setState(() {
      isGameResolvedBySolver = false; // Ocultamos overlay
    });
    _overlayController.reverse();
  }

  Future<void> solvePuzzleInBackground() async {
    try {
      PuzzleSolver solver = PuzzleSolver(
        gridSize: gridSize,
        targetPuzzle: solvedPuzzle,
      );

      // Ejecutar en compute para no bloquear UI
      solutionResult = await Future.microtask(
        () => solver.solvePuzzleComplete(List.from(currentPuzzle)),
      );

      if (solutionResult!.solvable) {
        solutionMoves = solutionResult!.moves;
        currentSolutionStep = 0;
      }
    } catch (e) {
      solutionResult = null;
    }

    setState(() {
      isSolving = false;
    });
  }

  Future<void> startSolutionAnimation() async {
    if (solutionMoves.isEmpty) return;

    setState(() {
      isAnimatingSolution = true;
    });
    gameTimer?.cancel();
    for (int i = 0; i < solutionMoves.length; i++) {
      await executeNextSolutionMove(solutionMoves[i]);
      await Future.delayed(Duration(milliseconds: 500));
    }
    await finishSolutionAnimation();
  }

  Future<void> executeNextSolutionMove(int moveIndex) async {
    if (!mounted) return;
    setState(() {
      movingPieceIndex = moveIndex;
      currentSolutionStep++;
    });
    _pieceController.reset();
    await _pieceController.forward();
    setState(() {
      movingPieceIndex = null;
    });
    swapPieces(moveIndex, emptyIndex);
  }

  Future<void> finishSolutionAnimation() async {
    setState(() {
      isAnimatingSolution = false;
    });
    await Future.delayed(Duration(milliseconds: 1000));
    await _overlayController.reverse();
    setState(() {
      isGameResolvedBySolver = false;
      solutionMoves.clear();
      currentSolutionStep = 0;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Puzzle resuelto automáticamente!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void showSolutionError() {
    _overlayController.reverse();
    setState(() {
      isGameResolvedBySolver = false;
      isSolving = false;
    });

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se pudo encontrar una solución para este puzzle.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget buildSolverResults() {
    if (solutionResult == null) return Container();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Column(
          children: [
            Text(
              'Resultado de la máquina',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Text(
                      'Movimientos: ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${solutionResult!.moveCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Tiempo: ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${solutionResult!.solutionTimeMs}ms',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Progreso: ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '$currentSolutionStep/${solutionMoves.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPuzzleGame() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: SizedBox(
        height: 270,
        width: 270,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
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
      height: 80,
      width: 80,
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
