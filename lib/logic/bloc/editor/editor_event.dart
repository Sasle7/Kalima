import 'package:equatable/equatable.dart';

sealed class EditorEvent extends Equatable {
  const EditorEvent();

  @override
  List<Object?> get props => [];
}

final class InsertText extends EditorEvent {
  final String text;
  final int position;

  const InsertText(this.text, this.position);

  @override
  List<Object?> get props => [text, position];
}

final class DeleteText extends EditorEvent {
  final int start;
  final int end;

  const DeleteText(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

final class SelectText extends EditorEvent {
  final int start;
  final int end;

  const SelectText(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

final class CursorMoved extends EditorEvent {
  final int position;

  const CursorMoved(this.position);

  @override
  List<Object?> get props => [position];
}

final class PasteText extends EditorEvent {
  final String text;

  const PasteText(this.text);

  @override
  List<Object?> get props => [text];
}

final class CutText extends EditorEvent {
  final int start;
  final int end;

  const CutText(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}
