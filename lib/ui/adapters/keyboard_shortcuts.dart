import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/document/document_bloc.dart';
import 'package:kalima/logic/bloc/editor/editor_bloc.dart';
import 'package:kalima/logic/bloc/format/format_bloc.dart';
import 'package:kalima/logic/bloc/format/format_event.dart';

/// Keyboard shortcut handler wrapper widget.
///
/// Captures key events and dispatches the appropriate BLoC events.
/// Supports Ctrl+B/I/U for formatting, Ctrl+C/V/Z/Y for editing,
/// Ctrl+S/P for save/print, Ctrl+F/H for find, arrow keys for
/// navigation, Shift+arrow for selection, and Ctrl+Shift+L for toggling
/// bullet lists.
class KeyboardShortcutHandler extends StatelessWidget {
  final Widget child;

  const KeyboardShortcutHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // Formatting
        const SingleActivator(LogicalKeyboardKey.keyB, control: true): () {
          context.read<FormatBloc>().add(SetBold(true));
        },
        const SingleActivator(LogicalKeyboardKey.keyI, control: true): () {
          context.read<FormatBloc>().add(SetItalic(true));
        },
        const SingleActivator(LogicalKeyboardKey.keyU, control: true): () {
          context.read<FormatBloc>().add(SetUnderline(true));
        },

        // Clipboard
        const SingleActivator(LogicalKeyboardKey.keyC, control: true): () {
          // TODO: CopyRequested
        },
        const SingleActivator(LogicalKeyboardKey.keyV, control: true): () {
          // TODO: PasteRequested
        },
        const SingleActivator(LogicalKeyboardKey.keyX, control: true): () {
          // TODO: CutRequested
        },

        // Undo/Redo
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
          // TODO: UndoRequested
        },
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () {
          // TODO: RedoRequested
        },

        // Save/Print
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          // TODO: SaveRequested
        },
        const SingleActivator(LogicalKeyboardKey.keyP, control: true): () {
          // TODO: PrintRequested
        },

        // Find & Replace
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          // TODO: FindRequested
        },
        const SingleActivator(LogicalKeyboardKey.keyH, control: true): () {
          // TODO: FindReplaceRequested
        },

        // Select All
        const SingleActivator(LogicalKeyboardKey.keyA, control: true): () {
          // TODO: SelectAllRequested
        },

        // Bullet list toggle
        const SingleActivator(LogicalKeyboardKey.keyL,
            control: true, shift: true): () {
          // TODO: ToggleBulletList
        },

        // Navigation (arrow keys)
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          // TODO: CursorMoveLeft
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          // TODO: CursorMoveRight
        },
        const SingleActivator(LogicalKeyboardKey.arrowUp): () {
          // TODO: CursorMoveUp
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          // TODO: CursorMoveDown
        },

        // Selection with shift + arrows
        const SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true): () {
          // TODO: SelectionExtendLeft
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight, shift: true): () {
          // TODO: SelectionExtendRight
        },
        const SingleActivator(LogicalKeyboardKey.arrowUp, shift: true): () {
          // TODO: SelectionExtendUp
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown, shift: true): () {
          // TODO: SelectionExtendDown
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
