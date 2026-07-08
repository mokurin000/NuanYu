import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ExportUtils {
  /// Opens Android SAF directory picker, then writes the JSON export to the
  /// user-chosen directory. Returns the full file path on success, or null if
  /// the user cancels.
  static Future<String?> exportToJson(Map<String, dynamic> data) async {
    final dirPath = await FilePicker.getDirectoryPath(
      dialogTitle: '选择导出目录',
    );

    if (dirPath == null) return null;

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final fileName = 'nuanyu_export_$timestamp.json';
    final file = File('$dirPath/$fileName');

    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(data);
    await file.writeAsString(jsonString, flush: true);

    return file.path;
  }
}
