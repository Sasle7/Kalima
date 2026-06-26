import 'document_model.dart';

abstract class DocumentParser {
  Future<DocumentModel> parse(String filePath);

  Future<void> save(DocumentModel document, String filePath);

  bool get supportsImport => true;

  bool get supportsExport => true;

  String get formatName;

  List<String> get supportedExtensions;
}
