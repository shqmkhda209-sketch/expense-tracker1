import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/transaction_model.dart';
import '../domain/entities/transaction_entity.dart';

/// سرویس مسئول خروجی گرفتن (Backup) و بازیابی (Restore) اطلاعات
/// به‌صورت یک فایل JSON محلی — کاملاً آفلاین، بدون هیچ سرور خارجی.
class BackupService {
  static const int backupFormatVersion = 1;

  /// تبدیل لیست تراکنش‌ها به فایل JSON و اشتراک‌گذاری/ذخیره آن
  Future<String> exportBackup(List<TransactionEntity> transactions) async {
    final Map<String, dynamic> payload = {
      'version': backupFormatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'transactions': transactions.map(TransactionModel.toJson).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(payload);

    final dir = await getTemporaryDirectory();
    final fileName = 'expense_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(jsonString);

    // نمایش پنجره اشتراک‌گذاری/ذخیره سیستم‌عامل
    await Share.shareXFiles([XFile(file.path)], text: 'نسخه پشتیبان حساب‌دار من');

    return file.path;
  }

  /// انتخاب یک فایل JSON توسط کاربر و استخراج لیست تراکنش‌ها از آن
  /// در صورت نامعتبر بودن فایل، Exception پرتاب می‌شود.
  Future<List<TransactionEntity>> pickAndParseBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) {
      throw Exception('cancelled');
    }

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final Map<String, dynamic> decoded = jsonDecode(content) as Map<String, dynamic>;

    final List<dynamic> rawList = decoded['transactions'] as List<dynamic>? ?? [];
    return rawList
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
