import 'package:project_1_puzzle/data/models/game/priority_queue.dart';
import 'package:project_1_puzzle/data/models/game/puzzle_state.dart';
import 'package:project_1_puzzle/data/models/game/solution_result.dart';

class PuzzleSolver {
  final int gridSize;
  final List<String> targetPuzzle;
  final Map<String, int> targetPositions = {};

  PuzzleSolver({required this.gridSize, required this.targetPuzzle}) {
    for (int i = 0; i < targetPuzzle.length; i++) {
      if (targetPuzzle[i] != 'X') {
        targetPositions[targetPuzzle[i]] = i;
      }
    }
  }
  int calculateEnhancedHeuristic(List<String> puzzle) {
    int manhattan = calculateManhattanDistance(puzzle);
    int linearConflict = calculateLinearConflict(puzzle);
    return manhattan + 2 * linearConflict;
  }

  int calculateManhattanDistance(List<String> puzzle) {
    int distance = 0;
    for (int i = 0; i < puzzle.length; i++) {
      String piece = puzzle[i];
      if (piece != 'X' && targetPositions.containsKey(piece)) {
        int targetIndex = targetPositions[piece]!;
        int currentRow = i ~/ gridSize;
        int currentCol = i % gridSize;
        int targetRow = targetIndex ~/ gridSize;
        int targetCol = targetIndex % gridSize;
        distance +=
            (currentRow - targetRow).abs() + (currentCol - targetCol).abs();
      }
    }
    return distance;
  }

  int calculateLinearConflict(List<String> puzzle) {
    int conflict = 0;
    for (int row = 0; row < gridSize; row++) {
      List<String> rowPieces = [];
      List<int> rowTargets = [];

      for (int col = 0; col < gridSize; col++) {
        int index = row * gridSize + col;
        String piece = puzzle[index];
        if (piece != 'X' && targetPositions.containsKey(piece)) {
          int targetIndex = targetPositions[piece]!;
          int targetRow = targetIndex ~/ gridSize;
          if (targetRow == row) {
            rowPieces.add(piece);
            rowTargets.add(targetIndex % gridSize);
          }
        }
      }

      conflict += countInversions(rowTargets);
    }
    for (int col = 0; col < gridSize; col++) {
      List<String> colPieces = [];
      List<int> colTargets = [];

      for (int row = 0; row < gridSize; row++) {
        int index = row * gridSize + col;
        String piece = puzzle[index];
        if (piece != 'X' && targetPositions.containsKey(piece)) {
          int targetIndex = targetPositions[piece]!;
          int targetCol = targetIndex % gridSize;
          if (targetCol == col) {
            colPieces.add(piece);
            colTargets.add(targetIndex ~/ gridSize);
          }
        }
      }

      conflict += countInversions(colTargets);
    }

    return conflict;
  }

  int countInversions(List<int> arr) {
    int inversions = 0;
    for (int i = 0; i < arr.length - 1; i++) {
      for (int j = i + 1; j < arr.length; j++) {
        if (arr[i] > arr[j]) {
          inversions++;
        }
      }
    }
    return inversions;
  }

  bool isSolved(List<String> puzzle) {
    for (int i = 0; i < puzzle.length; i++) {
      if (puzzle[i] != targetPuzzle[i]) {
        return false;
      }
    }
    return true;
  }

  List<int> getPossibleMoves(int emptyIndex) {
    List<int> moves = [];
    int row = emptyIndex ~/ gridSize;
    int col = emptyIndex % gridSize;

    if (row > 0) moves.add(emptyIndex - gridSize);
    if (row < gridSize - 1) moves.add(emptyIndex + gridSize);
    if (col > 0) moves.add(emptyIndex - 1);
    if (col < gridSize - 1) moves.add(emptyIndex + 1);

    return moves;
  }

  PuzzleState makeMove(PuzzleState state, int moveIndex) {
    List<String> newPuzzle = List.from(state.puzzle);

    String temp = newPuzzle[moveIndex];
    newPuzzle[moveIndex] = newPuzzle[state.emptyIndex];
    newPuzzle[state.emptyIndex] = temp;

    return PuzzleState(
      puzzle: newPuzzle,
      emptyIndex: moveIndex,
      gCost: state.gCost + 1,
      hCost: calculateEnhancedHeuristic(newPuzzle),
      parent: state,
      moveIndex: moveIndex,
    );
  }

  List<int>? solveWithAStar(
    List<String> initialPuzzle, {
    int maxNodes = 100000,
    int maxTime = 5000,
  }) {
    if (isSolved(initialPuzzle)) return [];

    DateTime startTime = DateTime.now();
    int nodesExplored = 0;

    int emptyIndex = initialPuzzle.indexOf('X');

    PuzzleState initialState = PuzzleState(
      puzzle: List.from(initialPuzzle),
      emptyIndex: emptyIndex,
      gCost: 0,
      hCost: calculateEnhancedHeuristic(initialPuzzle),
    );

    var openSet = PriorityQueue<PuzzleState>(
      (a, b) => a.fCost.compareTo(b.fCost),
    );
    var closedSet = <String>{};
    var openSetLookup = <String, PuzzleState>{};

    openSet.add(initialState);
    openSetLookup[initialState.key] = initialState;

    while (openSet.isNotEmpty && nodesExplored < maxNodes) {
      // Verificar timeout
      if (DateTime.now().difference(startTime).inMilliseconds > maxTime) {
        print('A* timeout después de ${nodesExplored} nodos');
        return null;
      }

      PuzzleState current = openSet.removeFirst();
      openSetLookup.remove(current.key);
      nodesExplored++;

      if (isSolved(current.puzzle)) {
        print('A* encontró solución en ${nodesExplored} nodos');
        return reconstructPath(current);
      }

      closedSet.add(current.key);

      List<int> possibleMoves = getPossibleMoves(current.emptyIndex);

      for (int moveIndex in possibleMoves) {
        PuzzleState neighbor = makeMove(current, moveIndex);

        if (closedSet.contains(neighbor.key)) continue;

        if (!openSetLookup.containsKey(neighbor.key) ||
            neighbor.gCost < openSetLookup[neighbor.key]!.gCost) {
          if (openSetLookup.containsKey(neighbor.key)) {
            openSet.remove(openSetLookup[neighbor.key]!);
          }

          openSet.add(neighbor);
          openSetLookup[neighbor.key] = neighbor;
        }
      }
    }

    print('A* no encontró solución en ${nodesExplored} nodos');
    return null;
  }

  List<int>? solveWithIDAStar(List<String> initialPuzzle, {int maxDepth = 80}) {
    if (isSolved(initialPuzzle)) return [];

    int emptyIndex = initialPuzzle.indexOf('X');
    int threshold = calculateEnhancedHeuristic(initialPuzzle);

    while (threshold <= maxDepth) {
      List<int> result = [];
      Set<String> visited = {};

      int newThreshold = idaSearch(
        initialPuzzle,
        emptyIndex,
        0,
        threshold,
        result,
        visited,
      );

      if (newThreshold == -1) {
        print('IDA* encontró solución en ${result.length} movimientos');
        return result;
      }

      if (newThreshold == threshold) {
        print('IDA* sin progreso en threshold $threshold');
        break;
      }

      threshold = newThreshold;
      print('IDA* aumentando threshold a $threshold');
    }

    print('IDA* no encontró solución hasta profundidad $maxDepth');
    return null;
  }

  int idaSearch(
    List<String> puzzle,
    int emptyIndex,
    int gCost,
    int threshold,
    List<int> path,
    Set<String> visited,
  ) {
    int hCost = calculateEnhancedHeuristic(puzzle);
    int fCost = gCost + hCost;

    if (fCost > threshold) return fCost;
    if (isSolved(puzzle)) return -1;

    String key = puzzle.join(',');
    if (visited.contains(key)) return threshold + 1;
    visited.add(key);

    int minThreshold = threshold + 1;
    List<int> possibleMoves = getPossibleMoves(emptyIndex);

    for (int moveIndex in possibleMoves) {
      if (path.isNotEmpty && path.last == moveIndex) continue;
      List<String> newPuzzle = List.from(puzzle);
      String temp = newPuzzle[moveIndex];
      newPuzzle[moveIndex] = newPuzzle[emptyIndex];
      newPuzzle[emptyIndex] = temp;

      path.add(moveIndex);

      int result = idaSearch(
        newPuzzle,
        moveIndex,
        gCost + 1,
        threshold,
        path,
        visited,
      );

      if (result == -1) return -1;
      if (result < minThreshold) minThreshold = result;

      path.removeLast();
    }

    visited.remove(key);
    return minThreshold;
  }

  SolutionResult solvePuzzleComplete(List<String> currentPuzzle) {
    DateTime startTime = DateTime.now();
    List<int>? solution;

    if (gridSize == 3) {
      solution = solveWithAStar(
        currentPuzzle,
        maxNodes: 200000,
        maxTime: 10000,
      );
    } else if (gridSize == 4) {
      solution = solveWithAStar(currentPuzzle, maxNodes: 50000, maxTime: 3000);
      if (solution == null) {
        print('A* falló, intentando IDA*...');
        solution = solveWithIDAStar(currentPuzzle, maxDepth: 60);
      }
    } else {
      solution = solveWithIDAStar(currentPuzzle, maxDepth: 80);
    }

    DateTime endTime = DateTime.now();
    int solutionTime = endTime.difference(startTime).inMilliseconds;

    return SolutionResult(
      moves: solution ?? [],
      solvable: solution != null,
      moveCount: solution?.length ?? 0,
      solutionTimeMs: solutionTime,
    );
  }

  List<int> reconstructPath(PuzzleState finalState) {
    List<int> path = [];
    PuzzleState? current = finalState;

    while (current?.parent != null) {
      path.add(current!.moveIndex);
      current = current.parent;
    }

    return path.reversed.toList();
  }
}
