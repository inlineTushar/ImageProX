import 'dart:io';
import 'dart:typed_data';

import '/app/data/services/storage_service.dart';

abstract class StorageService {
  Future<File> saveBytes(
    Uint8List bytes, {
    required StorageType type,
    required String filename,
  });

  Future<File> copyFile(
    File source, {
    required StorageType type,
    required String filename,
  });
}
