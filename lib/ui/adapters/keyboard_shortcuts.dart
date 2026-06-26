import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/logic/bloc/document/document_bloc.dart';
import 'package:kalima/logic/bloc/editor/editor_bloc.dart';
import 'package:kalima/logic/bloc/format/format_bloc.dart';

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
          context.read<FormatBloc>().add(const ToggleBold());
        },
        const SingleActivator(LogicalKeyboardKey.keyI, control: true): () {
          context.read<FormatBloc>().add(const ToggleItalic());
        },
        const SingleActivator(LogicalKeyboardKey.keyU, control: true): () {
          context.read<FormatBloc>().add(const ToggleUnderline());
        },

        // Clipboard
        const SingleActivator(LogicalKeyboardKey.keyC, control: true): () {
          context.read<EditorBloc>().add(const CopyRequested());
        },
        const SingleActivator(LogicalKeyboardKey.keyV, control: true): () {
          context.read<EditorBloc>().add(const PasteRequested());
        },
        const SingleActivator(LogicalKeyboardKey.keyX, control: true): () {
          context.read<EditorBloc>().add(const CutRequested());
        },

        // Undo/Redo
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
          context.read<DocumentBloc>().add(const UndoRequested());
        },
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () {
          context.read<DocumentBloc>().add(const RedoRequested());
        },

        // Save/Print
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          context.read<DocumentBloc>().add(const SaveRequested());
        },
        const SingleActivator(LogicalKeyboardKey.keyP, control: true): () {
          context.read<DocumentBloc>().add(const PrintRequested());
        },

        // Find & Replace
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          context.read<EditorBloc>().add(const FindRequested());
        },
        const SingleActivator(LogicalKeyboardKey.keyH, control: true): () {
          context.read<EditorBloc>().add(const FindReplaceRequested());
        },

        // Select All
        const SingleActivator(LogicalKeyboardKey.keyA, control: true): () {
          context.read<EditorBloc>().add(const SelectAllRequested());
        },

        // Bullet list toggle
        const SingleActivator(LogicalKeyboardKey.keyL,
            control: true, shift: true): () {
          context.read<FormatBloc>().add(const ToggleBulletList());
        },

        // Navigation (arrow keys)
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          context.read<EditorBloc>().add(const CursorMoveLeft());
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          context.read<EditorBloc>().add(const CursorMoveRight());
        },
        const SingleActivator(LogicalKeyboardKey.arrowUp): () {
          context.read<EditorBloc>().add(const CursorMoveUp());
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          context.read<EditorBloc>().add(const CursorMoveDown());
        },

        // Selection with shift + arrows
        const SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true): () {
          context.read<EditorBloc>().add(const SelectionExtendLeft());
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight, shift: true): () {
          context.read<EditorBloc>().add(const SelectionExtendRight());
        },
        const SingleActivator(LogicalKeyboardKey.arrowUp, shift: true): () {
          context.read<EditorBloc>().add(const SelectionExtendUp());
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown, shift: true): () {
          context.read<EditorBloc>().add(const SelectionExtendDown());
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
