import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum StorageType { face, document, pdf }

class StorageService {
  Future<File> saveBytes(
    List<int> bytes, {
    required StorageType type,
    required String filename,
  }) async {
    final dir = await _ensureDir(type);
    final file = File(p.join(dir.path, filename));
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<File> copyFile(
    File source, {
    required StorageType type,
    required String filename,
  }) async {
    final dir = await _ensureDir(type);
    final file = File(p.join(dir.path, filename));
    return source.copy(file.path);
  }

  Future<Directory> _ensureDir(StorageType type) async {
    final base = await getApplicationDocumentsDirectory();
    final folder = switch (type) {
      StorageType.face => 'processed/faces',
      StorageType.document => 'processed/documents',
      StorageType.pdf => 'processed/pdfs',
    };
    final dir = Directory(p.join(base.path, folder));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
