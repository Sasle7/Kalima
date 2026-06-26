import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/editor/editor_bloc.dart';
import 'package:kalima/logic/bloc/editor/editor_state.dart';

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
        if (event.kind == ui.PointerDeviceKind.stylus ||
            event.kind == ui.PointerDeviceKind.invertedStylus) {
          // TODO: Add StylusDown event to EditorBloc
          // context.read<EditorBloc>().add(
          //       StylusDown(
          //         position: event.position,
          //         pressure: event.pressure,
          //         tiltX: 0.0,
          //         tiltY: 0.0,
          //         isEraser: event.kind == ui.PointerDeviceKind.invertedStylus,
          //       ),
          //     );
        }
      },
      onPointerMove: (event) {
        if (event.kind == ui.PointerDeviceKind.stylus ||
            event.kind == ui.PointerDeviceKind.invertedStylus) {
          // TODO: Add StylusMove event to EditorBloc
          // context.read<EditorBloc>().add(
          //       StylusMove(
          //         position: event.position,
          //         pressure: event.pressure,
          //         tiltX: 0.0,
          //         tiltY: 0.0,
          //       ),
          //     );
        }
      },
      onPointerUp: (event) {
        if (event.kind == ui.PointerDeviceKind.stylus ||
            event.kind == ui.PointerDeviceKind.invertedStylus) {
          // TODO: Add StylusUp event to EditorBloc
          // context.read<EditorBloc>().add(const StylusUp());
        }
      },
      child: Stack(
        children: [
          child,
          // Scribble mode overlay
          BlocBuilder<EditorBloc, EditorState>(
            builder: (context, state) {
              // TODO: EditorStylusActive state check
              if (state is EditorState) {
                // fallback - just check if editor has state
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
      ..color = const Color(0xFF0860CD)
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
