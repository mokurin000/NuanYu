import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExportUtils {
  static Future<String> exportToJson(Map<String, dynamic> data) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final fileName = 'nuanyu_export_$timestamp.json';
    final file = File('${dir.path}/$fileName');

    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(data);
    await file.writeAsString(jsonString, flush: true);

    return file.path;
  }
}
