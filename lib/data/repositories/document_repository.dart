import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

import '../../engine/document/document_model.dart' as engine;
import '../datasources/local/isar_database.dart';
import '../datasources/local/local_file_manager.dart';
import '../datasources/remote/cloud_sync_service.dart';
import '../models/document_model.dart';

enum DocumentSaveStatus {
  saved,
  saving,
  error,
  notModified,
}

enum DocumentOpenStatus {
  success,
  notFound,
  corrupted,
  permissionDenied,
}

class DocumentOpenResult {
  final DocumentOpenStatus status;
  final engine.DocumentModel? document;
  final String? errorMessage;

  const DocumentOpenResult({
    required this.status,
    this.document,
    this.errorMessage,
  });
}

class DocumentRepository {
  final IsarDatabase _database;
  final LocalFileManager _fileManager;
  final CloudSyncService? _cloudSync;

  DocumentRepository({
    required IsarDatabase database,
    required LocalFileManager fileManager,
    CloudSyncService? cloudSync,
  })  : _database = database,
        _fileManager = fileManager,
        _cloudSync = cloudSync;

  Future<engine.DocumentModel> createNewDocument({
    String? title,
    bool isRtl = true,
  }) async {
    final now = DateTime.now();
    final documentId = const Uuid().v4();
    final actualTitle = title ?? 'Untitled';

    final docData = DocumentData.withId(
      documentId: documentId,
      title: actualTitle,
      createdAt: now,
      modifiedAt: now,
    );

    await _database.saveDocument(docData);

    return engine.DocumentModel(
      id: documentId,
      title: actualTitle,
      blocks: [
        engine.DocumentBlock(
          id: const Uuid().v4(),
          type: engine.BlockType.paragraph,
          textRuns: [const engine.TextRun('')],
          format: engine.BlockFormat(
            alignment: isRtl
                ? engine.TextAlignment.right
                : engine.TextAlignment.left,
            isRtl: isRtl,
          ),
        ),
      ],
      createdAt: now,
      modifiedAt: now,
      isRtl: isRtl,
    );
  }

  Future<DocumentOpenResult> openDocument(String documentId) async {
    try {
      final docData = await _database.getDocumentById(documentId);
      if (docData == null) {
        return DocumentOpenResult(
          status: DocumentOpenStatus.notFound,
          errorMessage: 'Document not found in database',
        );
      }

      final model = docData.toDocumentModel();

      await _database.updateLastOpened(documentId);

      return DocumentOpenResult(
        status: DocumentOpenStatus.success,
        document: model,
      );
    } catch (e) {
      return DocumentOpenResult(
        status: DocumentOpenStatus.corrupted,
        errorMessage: 'Failed to open document: $e',
      );
    }
  }

  Future<DocumentOpenResult> openDocumentFromFile(String filePath) async {
    try {
      final exists = await _fileManager.fileExists(filePath);
      if (!exists) {
        return DocumentOpenResult(
          status: DocumentOpenStatus.notFound,
          errorMessage: 'File not found: $filePath',
        );
      }

      final content = await _fileManager.readFile(filePath);
      final json = jsonDecode(content) as Map<String, dynamic>;
      final model = engine.DocumentModel.fromJson(json);

      var docData = await _database.getDocumentById(model.id);
      if (docData == null) {
        docData = DocumentData.fromDocumentModel(model);
        docData.filePath = filePath;
      } else {
        docData.filePath = filePath;
        docData.contentDelta =
            jsonEncode(model.blocks.map((b) => b.toJson()).toList());
        docData.modifiedAt = model.modifiedAt;
      }
      await _database.saveDocument(docData);
      await _database.updateLastOpened(model.id);

      return DocumentOpenResult(
        status: DocumentOpenStatus.success,
        document: model,
      );
    } catch (e) {
      return DocumentOpenResult(
        status: DocumentOpenStatus.corrupted,
        errorMessage: 'Failed to open file: $e',
      );
    }
  }

  Future<DocumentSaveStatus> saveDocument(
    engine.DocumentModel document, {
    String? filePath,
  }) async {
    try {
      var docData = await _database.getDocumentById(document.id);
      if (docData == null) {
        docData = DocumentData.fromDocumentModel(document);
      } else {
        docData.title = document.title;
        docData.contentDelta =
            jsonEncode(document.blocks.map((b) => b.toJson()).toList());
        docData.modifiedAt = DateTime.now();
      }

      if (filePath != null) {
        docData.filePath = filePath;
      }

      if (docData.filePath != null) {
        final json = jsonEncode(document.toJson());
        await _fileManager.writeFile(docData.filePath!, json);
      }

      await _database.saveDocument(docData);

      return DocumentSaveStatus.saved;
    } catch (e) {
      return DocumentSaveStatus.error;
    }
  }

  Future<bool> deleteDocument(String documentId) async {
    try {
      final docData = await _database.getDocumentById(documentId);
      if (docData != null && docData.filePath != null) {
        await _fileManager.deleteFile(docData.filePath!);
      }
      await _database.deleteDocumentById(documentId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<engine.DocumentModel>> listRecentDocuments({int limit = 20}) async {
    final docs = await _database.getRecentDocuments(limit: limit);
    return docs.map((d) => d.toDocumentModel()).toList();
  }

  Future<List<engine.DocumentModel>> listAllDocuments() async {
    final docs = await _database.getAllDocuments();
    return docs.map((d) => d.toDocumentModel()).toList();
  }

  Future<List<engine.DocumentModel>> getPinnedDocuments() async {
    final docs = await _database.getPinnedDocuments();
    return docs.map((d) => d.toDocumentModel()).toList();
  }

  Future<List<engine.DocumentModel>> searchDocuments(String query) async {
    if (query.trim().isEmpty) {
      return listRecentDocuments();
    }
    final docs = await _database.searchDocuments(query.trim());
    return docs.map((d) => d.toDocumentModel()).toList();
  }

  Future<void> togglePinned(String documentId) async {
    await _database.togglePinned(documentId);
  }

  Future<DocumentSaveStatus> duplicateDocument(
      String sourceDocumentId) async {
    try {
      final source = await _database.getDocumentById(sourceDocumentId);
      if (source == null) return DocumentSaveStatus.error;

      final copy = DocumentData.fromDocumentModel(source.toDocumentModel());
      copy.documentId = const Uuid().v4();
      copy.title = '${source.title} (Copy)';
      copy.createdAt = DateTime.now();
      copy.modifiedAt = DateTime.now();
      copy.isPinned = false;
      copy.filePath = null;

      await _database.saveDocument(copy);
      return DocumentSaveStatus.saved;
    } catch (_) {
      return DocumentSaveStatus.error;
    }
  }

  Future<SyncResult?> syncWithCloud() async {
    if (_cloudSync == null) return null;
    if (!_cloudSync.isAuthenticated) {
      return const SyncResult(
        success: false,
        errorMessage: 'Not authenticated with cloud service',
      );
    }

    final localDocs = await _database.getAllDocuments();

    return _cloudSync.syncAll(
      localDocuments: localDocs,
      getLocalDocument: (id) => _database.getDocumentById(id),
      saveLocalDocument: (doc) {
        _database.saveDocument(doc);
        return Future.value();
      },
    );
  }

  Future<bool> renameDocument(String documentId, String newTitle) async {
    try {
      final doc = await _database.getDocumentById(documentId);
      if (doc == null) return false;
      doc.title = newTitle;
      doc.modifiedAt = DateTime.now();
      await _database.saveDocument(doc);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, int>> getDocumentStatistics(String documentId) async {
    final doc = await _database.getDocumentById(documentId);
    if (doc == null) {
      return {
        'characters': 0,
        'words': 0,
        'paragraphs': 0,
        'pages': 0,
      };
    }

    final model = doc.toDocumentModel();
    int charCount = 0;
    int wordCount = 0;
    int paraCount = model.blocks.length;

    for (final block in model.blocks) {
      for (final run in block.textRuns) {
        charCount += run.text.length;
        wordCount += run.text
            .split(RegExp(r'[\s\n\r]+'))
            .where((w) => w.isNotEmpty)
            .length;
      }
    }

    return {
      'characters': charCount,
      'words': wordCount,
      'paragraphs': paraCount,
      'pages': (paraCount / 40).ceil().clamp(1, 999999),
    };
  }
}
