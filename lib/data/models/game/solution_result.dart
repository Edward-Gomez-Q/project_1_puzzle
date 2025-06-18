class SolutionResult {
  final List<int> moves;
  final bool solvable;
  final int moveCount;
  final int solutionTimeMs;

  SolutionResult({
    required this.moves,
    required this.solvable,
    required this.moveCount,
    required this.solutionTimeMs,
  });

  @override
  String toString() {
    return 'SolutionResult(solvable: $solvable, moves: $moveCount, time: ${solutionTimeMs}ms)';
  }
}
