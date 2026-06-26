import 'package:flutter/material.dart';

/// Interactive horizontal ruler widget.
///
/// Displays measurements and provides draggable margin markers,
/// first-line indent markers, and tab stop markers.
class RulerWidget extends StatefulWidget {
  /// Margin values in logical pixels (left, right, top indent).
  final double leftMargin;
  final double rightMargin;
  final double firstLineIndent;

  /// List of tab stops with their positions and types.
  final List<TabStop> tabStops;

  /// Callback when margins change.
  final ValueChanged<RulerMargins>? onMarginsChanged;

  /// Callback when a tab stop is added.
  final ValueChanged<double>? onTabStopAdded;

  const RulerWidget({
    super.key,
    this.leftMargin = 72.0,
    this.rightMargin = 72.0,
    this.firstLineIndent = 0.0,
    this.tabStops = const [],
    this.onMarginsChanged,
    this.onTabStopAdded,
  });

  @override
  State<RulerWidget> createState() => _RulerWidgetState();
}

class _RulerWidgetState extends State<RulerWidget> {
  static const double _rulerHeight = 28.0;
  static const double _markerWidth = 10.0;
  static const double _markerHeight = 14.0;
  static const double _snapThreshold = 4.0;

  late double _left;
  late double _right;
  late double _firstLine;
  late List<_DraggableTabStop> _tabStops;

  @override
  void initState() {
    super.initState();
    _left = widget.leftMargin;
    _right = widget.rightMargin;
    _firstLine = widget.firstLineIndent;
    _tabStops = widget.tabStops
        .map((ts) => _DraggableTabStop(position: ts.position, type: ts.type))
        .toList();
  }

  @override
  void didUpdateWidget(RulerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _left = widget.leftMargin;
    _right = widget.rightMargin;
    _firstLine = widget.firstLineIndent;
    _tabStops = widget.tabStops
        .map((ts) => _DraggableTabStop(position: ts.position, type: ts.type))
        .toList();
  }

  void _notifyMargins() {
    widget.onMarginsChanged?.call(RulerMargins(
      leftMargin: _left,
      rightMargin: _right,
      firstLineIndent: _firstLine,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _rulerHeight + 8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Ruler background and tick marks
              Positioned(
                left: 0,
                right: 0,
                top: 4,
                child: Container(
                  height: _rulerHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: CustomPaint(
                    painter: _RulerLinePainter(width: width),
                    size: Size(width, _rulerHeight),
                  ),
                ),
              ),
              // Margin markers (bottom triangle shapes)
              // Left margin marker
              Positioned(
                left: _left - _markerWidth / 2,
                top: 4 + _rulerHeight - _markerHeight,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final newLeft = (_left + details.delta.dx)
                        .clamp(0.0, _right - 40.0);
                    _left = newLeft;
                    setState(() {});
                    _notifyMargins();
                  },
                  child: CustomPaint(
                    size: const Size(_markerWidth, _markerHeight),
                    painter: _MarginMarkerPainter(
                      color: const Color(0xFF1A1A2E),
                      direction: _MarkerDirection.left,
                    ),
                  ),
                ),
              ),
              // First-line indent marker
              Positioned(
                left: _left + _firstLine - _markerWidth / 2,
                top: 4 + _rulerHeight - _markerHeight,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final newFirst = (_firstLine + details.delta.dx)
                        .clamp(-_left, width - _left - 20.0);

                    if ((newFirst - 0).abs() < _snapThreshold) {
                      _firstLine = 0;
                    } else {
                      _firstLine = newFirst;
                    }
                    setState(() {});
                    _notifyMargins();
                  },
                  child: CustomPaint(
                    size: const Size(_markerWidth, _markerHeight),
                    painter: _MarginMarkerPainter(
                      color: const Color(0xFF0860CD),
                      direction: _MarkerDirection.top,
                    ),
                  ),
                ),
              ),
              // Right margin marker
              Positioned(
                left: width - _right - _markerWidth / 2,
                top: 4 + _rulerHeight - _markerHeight,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final newRight = (_right - details.delta.dx)
                        .clamp(40.0, width - _left);
                    _right = newRight;
                    setState(() {});
                    _notifyMargins();
                  },
                  child: CustomPaint(
                    size: const Size(_markerWidth, _markerHeight),
                    painter: _MarginMarkerPainter(
                      color: const Color(0xFF1A1A2E),
                      direction: _MarkerDirection.right,
                    ),
                  ),
                ),
              ),
              // Tab stop markers
              ..._tabStops.map((ts) {
                return Positioned(
                  left: ts.position - 5,
                  top: 4 + 2,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _tabStops.remove(ts);
                      });
                    },
                    child: CustomPaint(
                      size: const Size(10, 18),
                      painter: _TabStopPainter(type: ts.type),
                    ),
                  ),
                );
              }),
              // Double tap to add tab stop
              Positioned.fill(
                top: 4,
                child: GestureDetector(
                  onDoubleTapDown: (details) {
                    final pos = details.localPosition.dx;
                    final types = TabStopType.values;
                    final existingTypes = _tabStops.map((t) => t.type).toSet();
                    final nextType = types.firstWhere(
                      (t) => !existingTypes.contains(t),
                      orElse: () => TabStopType.left,
                    );
                    setState(() {
                      _tabStops.add(_DraggableTabStop(
                        position: pos,
                        type: nextType,
                      ));
                    });
                    widget.onTabStopAdded?.call(pos);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Margin values produced by the ruler widget.
class RulerMargins {
  final double leftMargin;
  final double rightMargin;
  final double firstLineIndent;

  const RulerMargins({
    required this.leftMargin,
    required this.rightMargin,
    required this.firstLineIndent,
  });
}

/// Represents a tab stop.
class TabStop {
  final double position;
  final TabStopType type;

  const TabStop({required this.position, required this.type});
}

/// Types of tab stops.
enum TabStopType { left, right, center, decimal }

class _DraggableTabStop {
  double position;
  final TabStopType type;

  _DraggableTabStop({required this.position, required this.type});
}

enum _MarkerDirection { left, right, top }

class _MarginMarkerPainter extends CustomPainter {
  final Color color;
  final _MarkerDirection direction;

  _MarginMarkerPainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    switch (direction) {
      case _MarkerDirection.left:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width / 2, size.height);
        break;
      case _MarkerDirection.right:
        path.moveTo(size.width, 0);
        path.lineTo(0, 0);
        path.lineTo(size.width / 2, size.height);
        break;
      case _MarkerDirection.top:
        path.moveTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width / 2, 0);
        break;
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MarginMarkerPainter old) =>
      old.color != color || old.direction != direction;
}

class _RulerLinePainter extends CustomPainter {
  final double width;

  _RulerLinePainter({required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    const tickSpacing = 10.0;
    for (double x = 0; x < width; x += tickSpacing) {
      final isMajor = (x / tickSpacing) % 5 == 0;
      canvas.drawLine(
        Offset(x, isMajor ? 8 : 14),
        Offset(x, size.height),
        tickPaint,
      );
      if (isMajor) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${(x / tickSpacing).round()}',
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, 0));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RulerLinePainter old) => old.width != width;
}

class _TabStopPainter extends CustomPainter {
  final TabStopType type;

  _TabStopPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height);
    switch (type) {
      case TabStopType.left:
        canvas.drawLine(center, Offset(size.width / 2, 0), paint);
        canvas.drawLine(Offset(0, size.height), center, paint);
        break;
      case TabStopType.right:
        canvas.drawLine(center, Offset(size.width / 2, 0), paint);
        canvas.drawLine(Offset(size.width, size.height), center, paint);
        break;
      case TabStopType.center:
        canvas.drawLine(center, Offset(size.width / 2, 0), paint);
        canvas.drawLine(Offset(size.width / 4, size.height), Offset(size.width * 0.75, size.height), paint);
        break;
      case TabStopType.decimal:
        canvas.drawLine(center, Offset(size.width / 2, 0), paint);
        canvas.drawCircle(center, 3, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _TabStopPainter old) => old.type != type;
}
