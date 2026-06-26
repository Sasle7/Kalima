import 'package:equatable/equatable.dart';
import 'package:kalima/engine/document/document_model.dart';

sealed class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

final class DocumentInitial extends DocumentState {
  const DocumentInitial();
}

final class DocumentLoading extends DocumentState {
  const DocumentLoading();
}

final class DocumentLoaded extends DocumentState {
  final DocumentModel document;
  final String? filePath;
  final bool isModified;

  const DocumentLoaded({
    required this.document,
    this.filePath,
    this.isModified = false,
  });

  DocumentLoaded copyWith({
    DocumentModel? document,
    String? filePath,
    bool? isModified,
    bool clearFilePath = false,
  }) {
    return DocumentLoaded(
      document: document ?? this.document,
      filePath: clearFilePath ? null : (filePath ?? this.filePath),
      isModified: isModified ?? this.isModified,
    );
  }

  @override
  List<Object?> get props => [document, filePath, isModified];
}

final class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object?> get props => [message];
}
