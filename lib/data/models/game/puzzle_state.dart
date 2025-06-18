class PuzzleState {
  final List<String> puzzle;
  final int emptyIndex;
  final int gCost;
  final int hCost;
  final PuzzleState? parent;
  final int moveIndex;

  PuzzleState({
    required this.puzzle,
    required this.emptyIndex,
    required this.gCost,
    required this.hCost,
    this.parent,
    this.moveIndex = -1,
  });

  int get fCost => gCost + hCost;

  String get key => puzzle.join(',');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PuzzleState) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}
