import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/engine/document/document_model.dart';
import 'package:kalima/engine/document/delta_format.dart';
import 'package:kalima/logic/bloc/editor/editor_event.dart';
import 'package:kalima/logic/bloc/editor/editor_state.dart';

class EditorBloc extends Bloc<EditorEvent, EditorState> {
  static const int _maxUndoStack = 100;

  EditorBloc() : super(EditorState(document: DocumentModel.empty())) {
    on<InsertText>(_onInsertText);
    on<DeleteText>(_onDeleteText);
    on<SelectText>(_onSelectText);
    on<CursorMoved>(_onCursorMoved);
    on<PasteText>(_onPasteText);
    on<CutText>(_onCutText);
  }

  void _onInsertText(InsertText event, Emitter<EditorState> emit) {
    if (event.text.isEmpty) return;

    final delta = Delta.insertAt(event.position, event.text);
    final updatedDocument = state.document.applyDelta(delta);
    final newCursorPos = event.position + event.text.length;

    final undoStack = _pushUndo(delta);

    emit(state.copyWith(
      document: updatedDocument,
      cursorPosition: newCursorPos,
      undoStack: undoStack,
      redoStack: const [],
      isEditing: true,
      clearSelection: true,
    ));
  }

  void _onDeleteText(DeleteText event, Emitter<EditorState> emit) {
    final start = event.start < event.end ? event.start : event.end;
    final end = event.start < event.end ? event.end : event.start;

    if (start >= state.document.text.length || start < 0 || end <= start) return;

    final deletedText = state.document.text.substring(start, end);
    final delta = Delta.deleteAt(start, deletedText);
    final updatedDocument = state.document.applyDelta(delta);

    final undoStack = _pushUndo(delta);

    emit(state.copyWith(
      document: updatedDocument,
      cursorPosition: start,
      undoStack: undoStack,
      redoStack: const [],
      isEditing: true,
      clearSelection: true,
    ));
  }

  void _onSelectText(SelectText event, Emitter<EditorState> emit) {
    final start = event.start.clamp(0, state.document.text.length);
    final end = event.end.clamp(0, state.document.text.length);

    emit(state.copyWith(
      selectionStart: start,
      selectionEnd: end,
      cursorPosition: end,
    ));
  }

  void _onCursorMoved(CursorMoved event, Emitter<EditorState> emit) {
    final pos = event.position.clamp(0, state.document.text.length);

    emit(state.copyWith(
      cursorPosition: pos,
      clearSelection: true,
    ));
  }

  void _onPasteText(PasteText event, Emitter<EditorState> emit) {
    if (event.text.isEmpty) return;

    final pastePosition = state.selectionStart != null && state.selectionEnd != null
        ? state.effectiveSelectionStart
        : state.cursorPosition;

    if (state.selectionStart != null && state.selectionEnd != null &&
        state.selectionStart != state.selectionEnd) {
      add(DeleteText(state.effectiveSelectionStart, state.effectiveSelectionEnd));
    }

    final delta = Delta.insertAt(pastePosition, event.text);
    final updatedDocument = state.document.applyDelta(delta);
    final newCursorPos = pastePosition + event.text.length;

    final undoStack = _pushUndo(delta);

    emit(state.copyWith(
      document: updatedDocument,
      cursorPosition: newCursorPos,
      undoStack: undoStack,
      redoStack: const [],
      isEditing: true,
      clearSelection: true,
    ));
  }

  void _onCutText(CutText event, Emitter<EditorState> emit) {
    final start = event.start < event.end ? event.start : event.end;
    final end = event.start < event.end ? event.end : event.start;

    if (start >= state.document.text.length || start < 0 || end > state.document.text.length || end <= start) return;

    final delta = Delta.deleteAt(start, state.document.text.substring(start, end));
    final updatedDocument = state.document.applyDelta(delta);

    final undoStack = _pushUndo(delta);

    emit(state.copyWith(
      document: updatedDocument,
      cursorPosition: start,
      undoStack: undoStack,
      redoStack: const [],
      isEditing: true,
      clearSelection: true,
    ));
  }

  List<Delta> _pushUndo(Delta delta) {
    final stack = [...state.undoStack, delta];
    if (stack.length > _maxUndoStack) {
      stack.removeAt(0);
    }
    return stack;
  }

  void undo() {
    if (state.undoStack.isEmpty) return;

    final delta = state.undoStack.last;
    final reversed = delta.reversed;
    final updatedDocument = state.document.applyDelta(reversed);

    final undoStack = [...state.undoStack]..removeLast();
    final redoStack = [...state.redoStack, delta];
    if (redoStack.length > _maxUndoStack) {
      redoStack.removeAt(0);
    }

    emit(state.copyWith(
      document: updatedDocument,
      cursorPosition: _reversedCursor(delta, reversed),
      undoStack: undoStack,
      redoStack: redoStack,
      clearSelection: true,
    ));
  }

  void redo() {
    if (state.redoStack.isEmpty) return;

    final delta = state.redoStack.last;
    final updatedDocument = state.document.applyDelta(delta);

    final redoStack = [...state.redoStack]..removeLast();
    final undoStack = [...state.undoStack, delta];
    if (undoStack.length > _maxUndoStack) {
      undoStack.removeAt(0);
    }

    emit(state.copyWith(
      document: updatedDocument,
      cursorPosition: _forwardCursor(delta),
      undoStack: undoStack,
      redoStack: redoStack,
      clearSelection: true,
    ));
  }

  int _reversedCursor(Delta original, Delta reversed) {
    if (reversed.operation == DeltaOperation.insert) {
      return reversed.position;
    }
    if (reversed.operation == DeltaOperation.delete) {
      return reversed.position;
    }
    return state.cursorPosition;
  }

  int _forwardCursor(Delta delta) {
    if (delta.operation == DeltaOperation.insert) {
      return delta.position + (delta.text?.length ?? 0);
    }
    if (delta.operation == DeltaOperation.delete) {
      return delta.position;
    }
    return state.cursorPosition;
  }

  void applyFormatToSelection(Map<String, dynamic> attributes) {
    if (state.selectionStart == null || state.selectionEnd == null) return;
    if (state.selectionStart == state.selectionEnd) return;

    final start = state.effectiveSelectionStart;
    final end = state.effectiveSelectionEnd;

    final delta = Delta.retain(start, length: end - start, attributes: attributes);
    final updatedDocument = state.document.applyDelta(delta);

    final undoStack = _pushUndo(delta);

    emit(state.copyWith(
      document: updatedDocument,
      undoStack: undoStack,
      redoStack: const [],
      isEditing: true,
    ));
  }
}
