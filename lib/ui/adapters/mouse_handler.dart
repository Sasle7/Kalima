import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/editor/editor_bloc.dart';

/// Mouse interaction handler wrapper widget.
///
/// Manages mouse cursor changes (I-beam over text, resize over table edges),
/// double-click word selection, triple-click paragraph selection, and
/// scroll wheel support for the editor canvas.
class MouseHandler extends StatelessWidget {
  final Widget child;

  const MouseHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          // TODO: Add ScrollBy event to EditorBloc
          // context.read<EditorBloc>().add(
          //   ScrollBy(delta: event.scrollDelta.dy),
          // );
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        onHover: (event) {
          // Delegate to editor bloc to determine cursor type
          // based on what's under the pointer
          // TODO: Add PointerHovered event to EditorBloc
          // context.read<EditorBloc>().add(
          //   PointerHovered(position: event.position),
          // );
        },
        child: _MouseSelectionHandler(child: child),
      ),
    );
  }
}

/// Handles double-click and triple-click for word/paragraph selection.
class _MouseSelectionHandler extends StatefulWidget {
  final Widget child;

  const _MouseSelectionHandler({required this.child});

  @override
  State<_MouseSelectionHandler> createState() =>
      _MouseSelectionHandlerState();
}

class _MouseSelectionHandlerState extends State<_MouseSelectionHandler> {
  int _clickCount = 0;
  DateTime _lastClickTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        final now = DateTime.now();
        final diff = now.difference(_lastClickTime);

        if (diff.inMilliseconds < 300) {
          _clickCount++;
        } else {
          _clickCount = 1;
        }
        _lastClickTime = now;

        if (_clickCount == 2) {
          // TODO: Add WordSelected event to EditorBloc
          // context.read<EditorBloc>().add(
          //   WordSelected(
          //     pageIndex: 0,
          //     position: details.localPosition,
          //   ),
          // );
        } else if (_clickCount >= 3) {
          // TODO: Add ParagraphSelected event to EditorBloc
          // context.read<EditorBloc>().add(
          //   ParagraphSelected(
          //     pageIndex: 0,
          //     position: details.localPosition,
          //   ),
          // );
          _clickCount = 0;
        }
      },
      child: widget.child,
    );
  }
}
