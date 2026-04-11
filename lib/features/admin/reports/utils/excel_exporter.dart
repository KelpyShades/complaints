import 'package:excel/excel.dart';
import 'package:complaints/core/utils/file_saver/file_saver.dart';

import '../../../complaints/models/complaint_model.dart';
import '../../../../core/error/error_handler.dart';

abstract final class ExcelExporter {
  /// Exports the given complaints to an Excel file and presents a share/save dialog.
  static Future<bool> export(List<ComplaintModel> complaints) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Complaints'];
      
      // Delete default 'Sheet1'
      if (excel.tables.keys.contains('Sheet1')) {
        excel.delete('Sheet1');
      }

      // Headers
      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Title'),
        TextCellValue('Description'),
        TextCellValue('Category'),
        TextCellValue('Status'),
        TextCellValue('Created At'),
        TextCellValue('Updated At'),
        TextCellValue('Student ID'),
      ]);

      // Bold headers
      for (var i = 0; i < 8; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.cellStyle = CellStyle(bold: true);
      }

      // Rows
      for (final c in complaints) {
        sheet.appendRow([
          TextCellValue(c.id),
          TextCellValue(c.title),
          TextCellValue(c.description),
          TextCellValue(c.category),
          TextCellValue(c.status.label),
          TextCellValue(c.createdAt?.toIso8601String() ?? ''),
          TextCellValue(c.updatedAt?.toIso8601String() ?? ''),
          TextCellValue(c.userId),
        ]);
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) return false;

      final fileName = 'complaints_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      
      // Use the cross-platform file saver
      await saveAndShareFile(fileBytes, fileName);

      return true;
    } catch (e, st) {
      ErrorHandler.handle(e, st);
      return false;
    }
  }
}
