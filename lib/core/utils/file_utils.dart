import 'dart:io';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class FileUtils {
  FileUtils._();

  static const _uuid = Uuid();

  static const List<String> supportedExtensions = [
    '.kdoc',
    '.docx',
    '.pdf',
  ];

  static const List<String> importableExtensions = [
    '.docx',
  ];

  static const List<String> exportableExtensions = [
    '.pdf',
    '.docx',
  ];

  static const int maxFileSize = 50 * 1024 * 1024; // 50 MB

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static bool isExtensionSupported(String extension) {
    return supportedExtensions.contains(extension.toLowerCase());
  }

  static bool isExtensionImportable(String extension) {
    return importableExtensions.contains(extension.toLowerCase());
  }

  static bool isExtensionExportable(String extension) {
    return exportableExtensions.contains(extension.toLowerCase());
  }

  static bool isFileSizeValid(int bytes) {
    return bytes <= maxFileSize;
  }

  static String getExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return fileName.substring(dotIndex).toLowerCase();
  }

  static String getFileNameWithoutExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) return fileName;
    return fileName.substring(0, dotIndex);
  }

  static String sanitizeFileName(String name) {
    return name.replaceAll(
      RegExp(r'[<>:"/\\|?*]'),
      '_',
    );
  }

  static String generateDocumentFileName(String title) {
    final sanitized = sanitizeFileName(title.trim());
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    if (sanitized.isEmpty) return 'document_$timestamp.kdoc';
    return '${sanitized}_$timestamp.kdoc';
  }

  static String generateUniqueFileName(String extension) {
    final id = _uuid.v4().substring(0, 8);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final ext = extension.startsWith('.') ? extension : '.$extension';
    return 'kalima_$timestamp${id}$ext';
  }

  static Future<File> createTempFile({
    required String extension,
    String? directory,
  }) async {
    final dir = directory ?? Directory.systemTemp.path;
    final fileName = generateUniqueFileName(extension);
    final file = File('$dir/$fileName');
    return file.create(recursive: true);
  }

  static Future<String> createTempDirectory({String? prefix}) async {
    final dir = Directory.systemTemp.path;
    final name = '${prefix ?? 'kalima'}_${_uuid.v4().substring(0, 8)}';
    final directory = Directory('$dir/$name');
    await directory.create(recursive: true);
    return directory.path;
  }

  static Future<void> cleanTempDirectory(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  static Future<void> cleanOldTempFiles({
    Duration maxAge = const Duration(hours: 24),
  }) async {
    final tempDir = Directory.systemTemp;
    final now = DateTime.now();
    await for (final entity in tempDir.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        if (now.difference(stat.modified) > maxAge) {
          await entity.delete();
        }
      } else if (entity is Directory) {
        final stat = await entity.stat();
        if (now.difference(stat.modified) > maxAge) {
          await entity.delete(recursive: true);
        }
      }
    }
  }

  static Future<File> copyToDirectory({
    required File sourceFile,
    required String targetDirectory,
  }) async {
    final targetDir = Directory(targetDirectory);
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    final fileName = sourceFile.uri.pathSegments.last;
    final targetPath = '$targetDirectory/$fileName';
    return sourceFile.copy(targetPath);
  }

  static Future<void> ensureDirectoryExists(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
}
