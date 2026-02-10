import 'package:hive/hive.dart';

import '/app/data/models/history_item.dart';

const historyBoxName = 'history_items';

class HistoryTypeAdapter extends TypeAdapter<HistoryType> {
  @override
  final int typeId = 1;

  @override
  HistoryType read(BinaryReader reader) {
    final index = reader.readInt();
    return HistoryType.values[index];
  }

  @override
  void write(BinaryWriter writer, HistoryType obj) {
    writer.writeInt(obj.index);
  }
}

class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 2;

  @override
  HistoryItem read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < fieldCount; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return HistoryItem(
      id: fields[0] as String,
      type: fields[1] as HistoryType,
      title: (fields[2] as String?) ?? 'Document',
      createdAt: fields[3] as DateTime,
      originalPath: (fields[4] as String?) ?? '',
      processedPath: (fields[5] as String?) ?? '',
      thumbnailPath: fields[6] as String?,
      pdfPath: fields[7] as String?,
      extractedText: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.originalPath)
      ..writeByte(5)
      ..write(obj.processedPath)
      ..writeByte(6)
      ..write(obj.thumbnailPath)
      ..writeByte(7)
      ..write(obj.pdfPath)
      ..writeByte(8)
      ..write(obj.extractedText);
  }
}
