class PriorityQueue<T> {
  final List<T> _items = [];
  final int Function(T, T) _compare;

  PriorityQueue(this._compare);

  void add(T item) {
    _items.add(item);
    _bubbleUp(_items.length - 1);
  }

  T removeFirst() {
    if (_items.isEmpty) throw StateError('Queue is empty');

    T result = _items[0];
    T last = _items.removeLast();

    if (_items.isNotEmpty) {
      _items[0] = last;
      _bubbleDown(0);
    }

    return result;
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  bool remove(T item) {
    int index = _items.indexOf(item);
    if (index == -1) return false;

    if (index == _items.length - 1) {
      _items.removeLast();
      return true;
    }

    T last = _items.removeLast();
    _items[index] = last;

    if (_compare(last, item) < 0) {
      _bubbleUp(index);
    } else {
      _bubbleDown(index);
    }

    return true;
  }

  void _bubbleUp(int index) {
    while (index > 0) {
      int parentIndex = (index - 1) ~/ 2;
      if (_compare(_items[index], _items[parentIndex]) >= 0) break;

      _swap(index, parentIndex);
      index = parentIndex;
    }
  }

  void _bubbleDown(int index) {
    while (true) {
      int smallest = index;
      int leftChild = 2 * index + 1;
      int rightChild = 2 * index + 2;

      if (leftChild < _items.length &&
          _compare(_items[leftChild], _items[smallest]) < 0) {
        smallest = leftChild;
      }

      if (rightChild < _items.length &&
          _compare(_items[rightChild], _items[smallest]) < 0) {
        smallest = rightChild;
      }

      if (smallest == index) break;

      _swap(index, smallest);
      index = smallest;
    }
  }

  void _swap(int i, int j) {
    T temp = _items[i];
    _items[i] = _items[j];
    _items[j] = temp;
  }
}
