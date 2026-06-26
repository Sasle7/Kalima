import 'package:equatable/equatable.dart';
import 'package:kalima/engine/document/document_model.dart';
import 'package:kalima/engine/document/delta_format.dart';

class EditorState extends Equatable {
  final DocumentModel document;
  final int cursorPosition;
  final int? selectionStart;
  final int? selectionEnd;
  final bool isEditing;
  final List<Delta> undoStack;
  final List<Delta> redoStack;

  const EditorState({
    required this.document,
    this.cursorPosition = 0,
    this.selectionStart,
    this.selectionEnd,
    this.isEditing = false,
    this.undoStack = const [],
    this.redoStack = const [],
  });

  EditorState copyWith({
    DocumentModel? document,
    int? cursorPosition,
    int? selectionStart,
    int? selectionEnd,
    bool? isEditing,
    List<Delta>? undoStack,
    List<Delta>? redoStack,
    bool clearSelection = false,
  }) {
    return EditorState(
      document: document ?? this.document,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      selectionStart: clearSelection ? null : (selectionStart ?? this.selectionStart),
      selectionEnd: clearSelection ? null : (selectionEnd ?? this.selectionEnd),
      isEditing: isEditing ?? this.isEditing,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }

  int get selectionLength {
    if (selectionStart == null || selectionEnd == null) return 0;
    return (selectionEnd! - selectionStart!).abs();
  }

  int get effectiveSelectionStart {
    if (selectionStart == null || selectionEnd == null) return cursorPosition;
    return selectionStart! < selectionEnd! ? selectionStart! : selectionEnd!;
  }

  int get effectiveSelectionEnd {
    if (selectionStart == null || selectionEnd == null) return cursorPosition;
    return selectionStart! > selectionEnd! ? selectionStart! : selectionEnd!;
  }

  @override
  List<Object?> get props => [
        document,
        cursorPosition,
        selectionStart,
        selectionEnd,
        isEditing,
        undoStack,
        redoStack,
      ];
}
