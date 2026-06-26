import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalima/engine/document/document_model.dart';
import 'package:kalima/logic/bloc/document/document_event.dart';
import 'package:kalima/logic/bloc/document/document_state.dart';
import 'package:path_provider/path_provider.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  static const Duration _autoSaveInterval = Duration(seconds: 60);
  Timer? _autoSaveTimer;

  DocumentBloc() : super(const DocumentInitial()) {
    on<OpenDocument>(_onOpenDocument);
    on<CreateNewDocument>(_onCreateNewDocument);
    on<SaveDocument>(_onSaveDocument);
    on<ExportDocument>(_onExportDocument);
    on<CloseDocument>(_onCloseDocument);
  }

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }

  String? get _currentFilePath {
    final state = this.state;
    if (state is DocumentLoaded) return state.filePath;
    return null;
  }

  Future<void> _onOpenDocument(OpenDocument event, Emitter<DocumentState> emit) async {
    emit(const DocumentLoading());

    try {
      final file = File(event.filePath);
      if (!await file.exists()) {
        emit(DocumentError('File not found: ${event.filePath}'));
        return;
      }

      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      final document = DocumentModel.fromJson(json);

      _startAutoSave();
      emit(DocumentLoaded(
        document: document,
        filePath: event.filePath,
        isModified: false,
      ));
    } catch (e) {
      emit(DocumentError('Failed to open document: $e'));
    }
  }

  Future<void> _onCreateNewDocument(CreateNewDocument event, Emitter<DocumentState> emit) async {
    DocumentModel document;

    if (event.template != null) {
      try {
        document = await _loadTemplate(event.template!);
      } catch (_) {
        document = DocumentModel.empty();
      }
    } else {
      document = DocumentModel.empty();
    }

    _startAutoSave();
    emit(DocumentLoaded(
      document: document,
      isModified: false,
    ));
  }

  Future<void> _onSaveDocument(SaveDocument event, Emitter<DocumentState> emit) async {
    final currentState = state;
    if (currentState is! DocumentLoaded) return;

    try {
      final filePath = event.filePath ?? currentState.filePath;
      if (filePath == null) {
        emit(DocumentError('No file path specified'));
        return;
      }

      final file = File(filePath);
      await file.create(recursive: true);

      final json = currentState.document.toJson();
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );

      emit(currentState.copyWith(
        document: currentState.document,
        filePath: filePath,
        isModified: false,
      ));
    } catch (e) {
      emit(DocumentError('Failed to save document: $e'));
    }
  }

  Future<void> _onExportDocument(ExportDocument event, Emitter<DocumentState> emit) async {
    final currentState = state;
    if (currentState is! DocumentLoaded) return;

    try {
      switch (event.format.toLowerCase()) {
        case 'txt':
          await _exportAsText(currentState.document, event.path);
          break;
        case 'docx':
          await _exportAsDocx(currentState.document, event.path);
          break;
        case 'pdf':
          await _exportAsPdf(currentState.document, event.path);
          break;
        default:
          emit(DocumentError('Unsupported export format: ${event.format}'));
          return;
      }
    } catch (e) {
      emit(DocumentError('Failed to export document: $e'));
    }
  }

  void _onCloseDocument(CloseDocument event, Emitter<DocumentState> emit) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    emit(const DocumentInitial());
  }

  void markAsModified() {
    final currentState = state;
    if (currentState is DocumentLoaded) {
      emit(currentState.copyWith(isModified: true));
    }
  }

  void updateDocument(DocumentModel document) {
    final currentState = state;
    if (currentState is DocumentLoaded) {
      emit(currentState.copyWith(
        document: document,
        isModified: true,
      ));
    }
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) {
      _performAutoSave();
    });
  }

  Future<void> _performAutoSave() async {
    final currentState = state;
    if (currentState is! DocumentLoaded || !currentState.isModified) return;
    if (currentState.filePath == null) return;

    try {
      final file = File(currentState.filePath!);
      final json = currentState.document.toJson();
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );

      emit(currentState.copyWith(isModified: false));
    } catch (_) {
      // Silently fail on auto-save to avoid disrupting the user
    }
  }

  Future<DocumentModel> _loadTemplate(String templateName) async {
    final dir = await getApplicationDocumentsDirectory();
    final templateFile = File('${dir.path}/templates/$templateName.json');
    if (await templateFile.exists()) {
      final contents = await templateFile.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      return DocumentModel.fromJson(json);
    }
    throw Exception('Template not found: $templateName');
  }

  Future<void> _exportAsText(DocumentModel document, String path) async {
    final file = File(path);
    await file.writeAsString(document.text);
  }

  Future<void> _exportAsDocx(DocumentModel document, String path) async {
    final file = File(path);
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">');
    buffer.writeln('<w:body>');

    final paragraphs = document.text.split('\n');
    for (final paragraph in paragraphs) {
      buffer.writeln('<w:p>');
      buffer.writeln('<w:r>');
      buffer.writeln('<w:t>${_escapeXml(paragraph)}</w:t>');
      buffer.writeln('</w:r>');
      buffer.writeln('</w:p>');
    }

    buffer.writeln('</w:body>');
    buffer.writeln('</w:document>');
    await file.writeAsString(buffer.toString());
  }

  Future<void> _exportAsPdf(DocumentModel document, String path) async {
    final paragraphs = document.text.split('\n');
    final buffer = StringBuffer();
    buffer.writeln('%PDF-1.4');
    buffer.writeln('1 0 obj<</Type/Catalog/Pages 3 0 R>>endobj');
    buffer.writeln('2 0 obj<</Type/Page/Parent 3 0 R/MediaBox[0 0 612 792]/Contents 4 0 R/Resources<</Font<</F1 5 0 R>>>>>>endobj');
    buffer.writeln('3 0 obj<</Type/Pages/Kids[2 0 R]/Count 1>>endobj');

    final textContent = StringBuffer();
    textContent.writeln('BT');
    textContent.writeln('/F1 12 Tf');
    int y = 750;
    for (final paragraph in paragraphs) {
      if (paragraph.isNotEmpty) {
        textContent.writeln('1 0 0 1 50 $y Tm');
        textContent.writeln('(${_escapePdfString(paragraph)}) Tj');
        textContent.writeln('0 -15 Td');
        y -= 15;
      }
    }
    textContent.writeln('ET');

    final streamContent = textContent.toString();
    buffer.writeln('4 0 obj<</Length ${streamContent.length}>>stream');
    buffer.writeln(streamContent);
    buffer.writeln('endstream');
    buffer.writeln('5 0 obj<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>endobj');
    buffer.writeln('xref');
    buffer.writeln('0 6');
    buffer.writeln('0000000000 65535 f ');
    buffer.writeln('0000000009 00000 n ');
    buffer.writeln('0000000058 00000 n ');
    buffer.writeln('0000000115 00000 n ');
    buffer.writeln('0000000266 00000 n ');
    buffer.writeln('0000000367 00000 n ');
    buffer.writeln('trailer<</Size 6/Root 1 0 R>>');
    buffer.writeln('startxref');
    buffer.writeln('402');
    buffer.writeln('%%EOF');

    final file = File(path);
    await file.writeAsString(buffer.toString());
  }

  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  String _escapePdfString(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll('(', '\\(')
        .replaceAll(')', '\\)')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
