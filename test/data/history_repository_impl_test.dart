import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:imageprox/app/data/local/hive/history_adapters.dart';
import 'package:imageprox/app/data/models/history_item.dart';
import 'package:imageprox/app/data/repository/history_repository_impl.dart';
import 'package:imageprox/app/domain/repositories/history_repository.dart';

void main() {
  late Directory tempDir;
  late HistoryRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('imageprox_hive_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(HistoryTypeAdapter().typeId)) {
      Hive.registerAdapter(HistoryTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(HistoryItemAdapter().typeId)) {
      Hive.registerAdapter(HistoryItemAdapter());
    }
    await Hive.openBox<HistoryItem>(historyBoxName);
    repository = HistoryRepositoryImpl();
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('addHistoryItem stores item and loadHistory returns it', () async {
    final item = HistoryItem(
      id: '1',
      type: HistoryType.face,
      title: 'Face',
      createdAt: DateTime(2024, 1, 1),
      originalPath: '/o.jpg',
      processedPath: '/p.jpg',
    );

    await repository.addHistoryItem(item);

    final items = repository.loadHistory();
    expect(items, hasLength(1));
    expect(items.first.id, '1');
    expect(items.first.title, 'Face');
  });

  test('watchHistory emits updates', () async {
    final emitted = <List<HistoryItem>>[];
    final sub = repository.watchHistory().listen(emitted.add);

    final item = HistoryItem(
      id: '2',
      type: HistoryType.document,
      title: 'Doc',
      createdAt: DateTime(2024, 2, 2),
      originalPath: '/o2.jpg',
      processedPath: '/p2.jpg',
      pdfPath: '/d.pdf',
    );
    await repository.addHistoryItem(item);

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(emitted, isNotEmpty);
    expect(emitted.last.first.id, '2');
    expect(emitted.last.first.pdfPath, '/d.pdf');

    await sub.cancel();
  });
}
