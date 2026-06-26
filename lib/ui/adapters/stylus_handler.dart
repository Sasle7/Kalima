import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/editor/editor_bloc.dart';

/// Stylus input handler wrapper widget.
///
/// Provides pressure and tilt sensitivity handling, scribble mode
/// (handwriting to text), and a free-hand annotation layer for
/// stylus-enabled devices.
class StylusHandler extends StatelessWidget {
  final Widget child;

  const StylusHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.stylus ||
            event.kind == PointerDeviceKind.invertedStylus) {
          context.read<EditorBloc>().add(
                StylusDown(
                  position: event.position,
                  pressure: event.pressure,
                  tiltX: event.tiltX,
                  tiltY: event.tiltY,
                  isEraser: event.kind == PointerDeviceKind.invertedStylus,
                ),
              );
        }
      },
      onPointerMove: (event) {
        if (event.kind == PointerDeviceKind.stylus ||
            event.kind == PointerDeviceKind.invertedStylus) {
          context.read<EditorBloc>().add(
                StylusMove(
                  position: event.position,
                  pressure: event.pressure,
                  tiltX: event.tiltX,
                  tiltY: event.tiltY,
                ),
              );
        }
      },
      onPointerUp: (event) {
        if (event.kind == PointerDeviceKind.stylus ||
            event.kind == PointerDeviceKind.invertedStylus) {
          context.read<EditorBloc>().add(const StylusUp());
        }
      },
      child: Stack(
        children: [
          child,
          // Scribble mode overlay
          BlocBuilder<EditorBloc, EditorState>(
            builder: (context, state) {
              if (state is EditorStylusActive && state.showAnnotationLayer) {
                return Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _StylusAnnotationPainter(
                        strokes: state.annotationStrokes ?? [],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

/// Paints stylus annotation strokes on the canvas overlay.
class _StylusAnnotationPainter extends CustomPainter {
  final List<List<_StylusPoint>> strokes;

  _StylusAnnotationPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5B143)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final path = Path();
      path.moveTo(stroke.first.x, stroke.first.y);

      for (int i = 1; i < stroke.length; i++) {
        final p = stroke[i];
        final prev = stroke[i - 1];

        // Vary stroke width based on pressure
        paint.strokeWidth = (p.pressure * 4).clamp(0.5, 8.0);

        path.lineTo(p.x, p.y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StylusAnnotationPainter old) =>
      old.strokes != strokes;
}

/// A single point in a stylus stroke.
class _StylusPoint {
  final double x;
  final double y;
  final double pressure;
  final double tiltX;
  final double tiltY;

  const _StylusPoint({
    required this.x,
    required this.y,
    this.pressure = 0.5,
    this.tiltX = 0,
    this.tiltY = 0,
  });
}
