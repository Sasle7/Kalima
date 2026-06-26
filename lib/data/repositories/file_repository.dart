import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../datasources/local/local_file_manager.dart';

enum FileFormat {
  kalima('Kalima Document', 'kalima'),
  docx('Word Document', 'docx'),
  pdf('PDF Document', 'pdf'),
  txt('Plain Text', 'txt'),
  rtf('Rich Text Format', 'rtf'),
  html('HTML Document', 'html'),
  markdown('Markdown', 'md');

  final String displayName;
  final String extension;
  const FileFormat(this.displayName, this.extension);

  String get filter => '$displayName (*.$extension)';
  String get pattern => '*.$extension';
}

class FilePickResult {
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final FileFormat? format;
  final bool cancelled;

  const FilePickResult({
    this.filePath,
    this.fileName,
    this.fileSize,
    this.format,
    this.cancelled = false,
  });

  bool get isSuccess => filePath != null && !cancelled;
}

class FileRepository {
  final LocalFileManager _fileManager;

  FileRepository({required LocalFileManager fileManager})
      : _fileManager = fileManager;

  FileFormat _detectFormat(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    for (final format in FileFormat.values) {
      if (format.extension == ext) return format;
    }
    return FileFormat.txt;
  }

  Future<FilePickResult> pickFile({
    List<FileFormat>? allowedFormats,
    bool allowMultiple = false,
  }) async {
    final formats = allowedFormats ?? FileFormat.values;
    final filters = formats.map((f) => f.pattern).toList();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: formats.map((f) => f.extension).toList(),
        allowMultiple: allowMultiple,
      );

      if (result == null || result.files.isEmpty) {
        return const FilePickResult(cancelled: true);
      }

      final file = result.files.first;
      final format = _detectFormat(file.name);

      return FilePickResult(
        filePath: file.path,
        fileName: file.name,
        fileSize: file.size,
        format: format,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> saveFile({
    required String content,
    required String defaultFileName,
    FileFormat? format,
  }) async {
    final targetFormat = format ?? _detectFormat(defaultFileName);
    final fileName = defaultFileName.endsWith('.${targetFormat.extension}')
        ? defaultFileName
        : '$defaultFileName.${targetFormat.extension}';

    try {
      final result = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: [targetFormat.extension],
        fileName: fileName,
      );

      if (result == null) return null;

      await _fileManager.writeFile(result, content);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> saveFileBytes({
    required List<int> bytes,
    required String defaultFileName,
    FileFormat? format,
  }) async {
    final targetFormat = format ?? _detectFormat(defaultFileName);
    final fileName = defaultFileName.endsWith('.${targetFormat.extension}')
        ? defaultFileName
        : '$defaultFileName.${targetFormat.extension}';

    try {
      final result = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: [targetFormat.extension],
        fileName: fileName,
      );

      if (result == null) return null;

      await _fileManager.writeFileBytes(result, bytes);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> exportFile({
    required String sourcePath,
    required FileFormat targetFormat,
    String? outputFileName,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('Source file not found', sourcePath);
    }

    final baseName = outputFileName ?? 'export';
    final outputName = baseName.endsWith('.${targetFormat.extension}')
        ? baseName
        : '$baseName.${targetFormat.extension}';

    final outputDir = await getApplicationDocumentsDirectory();
    final outputPath = '${outputDir.path}/$outputName';

    await sourceFile.copy(outputPath);
    return outputPath;
  }

  Future<FilePickResult> importFile({
    List<FileFormat>? allowedFormats,
  }) async {
    return pickFile(allowedFormats: allowedFormats);
  }

  Future<String?> importToAppStorage(String sourcePath) async {
    final file = File(sourcePath);
    if (!await file.exists()) return null;

    final fileName = file.uri.pathSegments.last;
    final appDir = await getApplicationDocumentsDirectory();
    final destPath = '${appDir.path}/imports/$fileName';

    await _fileManager.createDirectory('${appDir.path}/imports');
    await file.copy(destPath);
    return destPath;
  }

  bool isValidFormat(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return FileFormat.values.any((f) => f.extension == ext);
  }

  String? getFormatExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    final format = FileFormat.values.firstWhere(
      (f) => f.extension == ext,
      orElse: () => FileFormat.txt,
    );
    return format.extension;
  }

  Future<Uint8List> readFileBytes(String path) async {
    final bytes = await _fileManager.readFileBytes(path);
    return Uint8List.fromList(bytes);
  }

  Future<String> readFileText(String path) async {
    return _fileManager.readFile(path);
  }

  Future<bool> deleteFile(String path) async {
    return _fileManager.deleteFile(path);
  }
}
