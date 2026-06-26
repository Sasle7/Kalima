import 'dart:async';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/document_model.dart';

class IsarDatabase {
  IsarDatabase._();

  static final IsarDatabase _instance = IsarDatabase._();
  static IsarDatabase get instance => _instance;

  Isar? _isar;
  bool _initialized = false;
  Completer<void>? _initCompleter;

  bool get isInitialized => _initialized;

  Isar get isar {
    if (_isar == null) {
      throw StateError('IsarDatabase not initialized. Call init() first.');
    }
    return _isar!;
  }

  Future<void> init() async {
    if (_initialized) return;
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<void>();
    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [DocumentDataSchema],
        directory: dir.path,
        inspector: true,
      );
      _initialized = true;
      _initCompleter!.complete();
    } catch (e) {
      _initCompleter!.completeError(e);
      rethrow;
    }
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
    _initialized = false;
    _initCompleter = null;
  }

  Future<T> write<T>(Future<T> Function(Isar isar) callback) async {
    return callback(isar);
  }

  Future<List<DocumentData>> getAllDocuments() async {
    return isar.documentDatas.where().findAll();
  }

  Future<DocumentData?> getDocumentById(String documentId) async {
    return isar.documentDatas
        .where()
        .documentIdEqualTo(documentId)
        .findFirst();
  }

  Future<DocumentData?> getDocumentByIsarId(Id id) async {
    return isar.documentDatas.get(id);
  }

  Future<Id> saveDocument(DocumentData document) async {
    return isar.writeTxn(() async {
      return isar.documentDatas.put(document);
    });
  }

  Future<bool> deleteDocument(Id id) async {
    return isar.writeTxn(() async {
      return isar.documentDatas.delete(id);
    });
  }

  Future<int> deleteDocumentById(String documentId) async {
    return isar.writeTxn(() async {
      return isar.documentDatas
          .where()
          .documentIdEqualTo(documentId)
          .deleteAll();
    });
  }

  Future<List<DocumentData>> searchDocuments(String query) async {
    if (query.isEmpty) return getAllDocuments();
    return isar.documentDatas
        .where()
        .titleMatches('*$query*')
        .findAll();
  }

  Future<List<DocumentData>> getRecentDocuments({int limit = 20}) async {
    return isar.documentDatas
        .where()
        .sortByModifiedAtDesc()
        .limit(limit)
        .findAll();
  }

  Future<List<DocumentData>> getPinnedDocuments() async {
    return isar.documentDatas
        .where()
        .filter()
        .isPinnedEqualTo(true)
        .findAll();
  }

  Future<void> updateLastOpened(String documentId) async {
    await isar.writeTxn(() async {
      final docs = await isar.documentDatas
          .where()
          .documentIdEqualTo(documentId)
          .findAll();
      for (final doc in docs) {
        doc.lastOpenedAt = DateTime.now();
        await isar.documentDatas.put(doc);
      }
    });
  }

  Future<void> togglePinned(String documentId) async {
    await isar.writeTxn(() async {
      final docs = await isar.documentDatas
          .where()
          .documentIdEqualTo(documentId)
          .findAll();
      for (final doc in docs) {
        doc.isPinned = !doc.isPinned;
        await isar.documentDatas.put(doc);
      }
    });
  }

  Future<int> clearAllDocuments() async {
    return isar.writeTxn(() async {
      return isar.documentDatas.where().deleteAll();
    });
  }
}
