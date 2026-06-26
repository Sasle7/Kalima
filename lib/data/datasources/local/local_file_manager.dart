import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalFileManager {
  LocalFileManager._();
  static final LocalFileManager _instance = LocalFileManager._();
  static LocalFileManager get instance => _instance;

  String? _documentsDir;
  String? _tempDir;

  Future<String> getDocumentsDirectory() async {
    if (_documentsDir != null) return _documentsDir!;
    final dir = await getApplicationDocumentsDirectory();
    _documentsDir = dir.path;
    return _documentsDir!;
  }

  Future<String> getTempDirectory() async {
    if (_tempDir != null) return _tempDir!;
    final dir = await getTemporaryDirectory();
    _tempDir = dir.path;
    return _tempDir!;
  }

  Future<String> getAppSupportDirectory() async {
    final dir = await getApplicationSupportDirectory();
    return dir.path;
  }

  Future<String> resolvePath(String relativePath) async {
    if (relativePath.startsWith('/')) return relativePath;
    final docsDir = await getDocumentsDirectory();
    return '$docsDir/$relativePath';
  }

  Future<String> readFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('File not found', path);
    }
    return file.readAsString();
  }

  Future<List<int>> readFileBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('File not found', path);
    }
    return file.readAsBytes();
  }

  Future<void> writeFile(String path, String content) async {
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsString(content);
  }

  Future<void> writeFileBytes(String path, List<int> bytes) async {
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  Future<String> copyFile(String sourcePath, String destPath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('Source file not found', sourcePath);
    }
    final dest = File(destPath);
    await dest.create(recursive: true);
    await source.copy(destPath);
    return destPath;
  }

  Future<bool> deleteFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return false;
    await file.delete();
    return true;
  }

  Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  Future<int> getFileSize(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    return file.length();
  }

  Future<DateTime> getLastModified(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('File not found', path);
    }
    return file.lastModified();
  }

  Future<List<String>> listFiles(String directoryPath,
      {String? extension}) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return [];

    final entities = dir.listSync();
    final files = <String>[];
    for (final entity in entities) {
      if (entity is File) {
        if (extension == null || entity.path.endsWith(extension)) {
          files.add(entity.path);
        }
      }
    }
    return files;
  }

  Future<bool> createDirectory(String path) async {
    final dir = Directory(path);
    await dir.create(recursive: true);
    return true;
  }

  Future<bool> deleteDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return false;
    await dir.delete(recursive: true);
    return true;
  }

  Future<String> createTempFile(String prefix, String suffix,
      {List<int>? bytes, String? content}) async {
    final tempDir = await getTempDirectory();
    final path = '$tempDir/${prefix}_${DateTime.now().millisecondsSinceEpoch}$suffix';
    if (bytes != null) {
      await writeFileBytes(path, bytes);
    } else if (content != null) {
      await writeFile(path, content);
    } else {
      await writeFile(path, '');
    }
    return path;
  }

  Future<String> createTempDirectory(String prefix) async {
    final tempDir = await getTempDirectory();
    final path = '$tempDir/${prefix}_${DateTime.now().millisecondsSinceEpoch}';
    await createDirectory(path);
    return path;
  }

  bool isValidFileName(String name) {
    if (name.isEmpty || name.length > 255) return false;
    final forbidden = ['/', '\\', ':', '*', '?', '"', '<', '>', '|', '\0'];
    return !forbidden.any((c) => name.contains(c));
  }

  String sanitizeFileName(String name) {
    final forbidden = ['/', '\\', ':', '*', '?', '"', '<', '>', '|', '\0'];
    var sanitized = name;
    for (final c in forbidden) {
      sanitized = sanitized.replaceAll(c, '_');
    }
    return sanitized.trim();
  }
}
