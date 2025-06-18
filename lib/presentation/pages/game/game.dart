import 'package:flutter/material.dart';

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

class _GameState extends State<Game> {
  int moves = 0;
  Duration timeElapsed = Duration.zero;

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
                        onPressed: () {},
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
    // Placeholder for the actual puzzle game widget
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Center(
            child: Text(
              'Puzzle Game Area',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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
