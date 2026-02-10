import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '/app/data/services/storage_service.dart';
import '/app/domain/services/storage_service.dart';

class StorageServiceImpl implements StorageService {
  @override
  Future<File> saveBytes(
    Uint8List bytes, {
    required StorageType type,
    required String filename,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = _folderFor(type);
    final targetDir = Directory(p.join(dir.path, folder));
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    final file = File(p.join(targetDir.path, filename));
    return file.writeAsBytes(bytes, flush: true);
  }

  @override
  Future<File> copyFile(
    File source, {
    required StorageType type,
    required String filename,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = _folderFor(type);
    final targetDir = Directory(p.join(dir.path, folder));
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    final file = File(p.join(targetDir.path, filename));
    return source.copy(file.path);
  }

  String _folderFor(StorageType type) {
    switch (type) {
      case StorageType.face:
        return 'processed/faces';
      case StorageType.document:
        return 'processed/documents';
      case StorageType.pdf:
        return 'processed/pdfs';
    }
  }
}
