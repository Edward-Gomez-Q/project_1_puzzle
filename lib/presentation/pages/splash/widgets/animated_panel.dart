import 'package:flutter/material.dart';
import 'package:project_1_puzzle/data/models/data_circle_model.dart';

class AnimatedColorPanel extends StatefulWidget {
  final double height;
  final double width;
  final Duration duration;

  const AnimatedColorPanel({
    super.key,
    required this.height,
    required this.width,
    required this.duration,
  });

  @override
  State<AnimatedColorPanel> createState() => _AnimatedColorPanelState();
}

class _AnimatedColorPanelState extends State<AnimatedColorPanel>
    with SingleTickerProviderStateMixin {
  final int circleCount = 20;
  late List<CircleData> circles;
  late AnimationController _controller;
  static const List<Color> _colorPattern = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFF44336),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFFEB3B),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFFE91E63),
    Color(0xFF8BC34A),
    Color(0xFFFF5722),
    Color(0xFF673AB7),
    Color(0xFF009688),
    Color(0xFFFFC107),
    Color(0xFF3F51B5),
    Color(0xFFCDDC39),
    Color(0xFF9E9E9E),
    Color(0xFF03A9F4),
    Color(0xFF4CAF50),
  ];

  static const List<double> _sizePattern = [
    15,
    25,
    35,
    20,
    30,
    18,
    28,
    22,
    32,
    16,
    24,
    36,
    19,
    27,
    21,
    33,
    17,
    29,
    23,
    31,
  ];

  int _animationCycle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _generateInitialCircles();
    _startAnimationLoop();
  }

  void _generateInitialCircles() {
    circles = List.generate(circleCount, (i) => _createCircle(i, 0));
  }

  CircleData _createCircle(int index, int cycle) {
    final double xFactor = ((index * 7 + cycle * 3) % 100) / 100.0;
    final double yFactor = ((index * 11 + cycle * 5) % 100) / 100.0;

    return CircleData(
      left: xFactor * (widget.width - _sizePattern[index]),
      top: yFactor * (widget.height - _sizePattern[index]),
      color: _colorPattern[index],
      size: _sizePattern[index],
    );
  }

  void _startAnimationLoop() async {
    while (mounted) {
      await Future.delayed(widget.duration);
      if (mounted) {
        setState(() {
          _animationCycle++;
          for (int i = 0; i < circles.length; i++) {
            final newCircle = _createCircle(i, _animationCycle);
            circles[i] = CircleData(
              left: newCircle.left,
              top: newCircle.top,
              color:
                  _colorPattern[(i + _animationCycle) % _colorPattern.length],
              size: circles[i].size,
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Stack(
          children: circles.map((circle) {
            return AnimatedPositioned(
              duration: widget.duration,
              curve: Curves.easeInOut,
              left: circle.left,
              top: circle.top,
              child: AnimatedContainer(
                duration: widget.duration,
                curve: Curves.easeInOut,
                width: circle.size,
                height: circle.size,
                decoration: BoxDecoration(
                  color: circle.color.withValues(alpha: 0.6),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
