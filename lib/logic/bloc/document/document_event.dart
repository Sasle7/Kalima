import 'package:equatable/equatable.dart';

sealed class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

final class OpenDocument extends DocumentEvent {
  final String filePath;

  const OpenDocument(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

final class CreateNewDocument extends DocumentEvent {
  final String? template;

  const CreateNewDocument({this.template});

  @override
  List<Object?> get props => [template];
}

final class SaveDocument extends DocumentEvent {
  final String? filePath;

  const SaveDocument({this.filePath});

  @override
  List<Object?> get props => [filePath];
}

final class ExportDocument extends DocumentEvent {
  final String format;
  final String path;

  const ExportDocument(this.format, this.path);

  @override
  List<Object?> get props => [format, path];
}

final class CloseDocument extends DocumentEvent {
  const CloseDocument();

  @override
  List<Object?> get props => [];
}
