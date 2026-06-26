import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../engine/document/document_model.dart' as engine;

part 'document_model.g.dart';

@collection
@Name('Documents')
class DocumentData {
  Id id = Isar.autoIncrement;

  @Index()
  late String documentId;

  @Index()
  late String title;

  String? filePath;

  late DateTime createdAt;

  late DateTime modifiedAt;

  String contentDelta = '';

  String metadataJson = '';

  bool isPinned = false;

  DateTime? lastOpenedAt;

  DocumentData() {
    documentId = const Uuid().v4();
    title = '';
    createdAt = DateTime.now();
    modifiedAt = DateTime.now();
  }

  Map<String, dynamic> get metadata {
    if (metadataJson.isEmpty) return {};
    try {
      return json.decode(metadataJson) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  set metadata(Map<String, dynamic> value) {
    metadataJson = json.encode(value);
  }

  engine.DocumentModel toDocumentModel() {
    final blocks = <engine.DocumentBlock>[];
    if (contentDelta.isNotEmpty) {
      try {
        final decoded = json.decode(contentDelta);
        if (decoded is List) {
          for (final item in decoded) {
            blocks.add(engine.DocumentBlock.fromJson(item as Map<String, dynamic>));
          }
        }
      } catch (_) {}
    }

    return engine.DocumentModel(
      id: documentId,
      title: title,
      blocks: blocks,
      metadata: engine.DocumentMetadata.fromJson(metadata),
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      isRtl: true,
    );
  }

  static DocumentData fromDocumentModel(engine.DocumentModel model) {
    final data = DocumentData();
    data.documentId = model.id;
    data.title = model.title;
    data.contentDelta = json.encode(model.blocks.map((b) => b.toJson()).toList());
    data.metadataJson = json.encode(model.metadata.toJson());
    data.createdAt = model.createdAt;
    data.modifiedAt = model.modifiedAt;
    return data;
  }

  static DocumentData withId({
    required String documentId,
    required String title,
    String? filePath,
    String contentDelta = '',
    Map<String, dynamic> metadata = const {},
    bool isPinned = false,
    DateTime? createdAt,
    DateTime? modifiedAt,
    DateTime? lastOpenedAt,
  }) {
    final data = DocumentData();
    data.documentId = documentId;
    data.title = title;
    data.filePath = filePath;
    data.contentDelta = contentDelta;
    data.metadata = metadata;
    data.isPinned = isPinned;
    data.createdAt = createdAt ?? DateTime.now();
    data.modifiedAt = modifiedAt ?? DateTime.now();
    data.lastOpenedAt = lastOpenedAt;
    return data;
  }
}
