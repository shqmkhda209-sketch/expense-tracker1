import '../../core/constants/app_categories.dart';
import '../../domain/entities/transaction_entity.dart';

/// مدل داده‌ای تراکنش؛ مسئول تبدیل بین ردیف‌های SQLite (Map) و TransactionEntity
class TransactionModel {
  static const String table = 'transactions';

  static const String colId = 'id';
  static const String colAmount = 'amount';
  static const String colTitle = 'title';
  static const String colCategory = 'category';
  static const String colType = 'type';
  static const String colDate = 'date';
  static const String colDescription = 'description';
  static const String colCreatedAt = 'created_at';

  static const String createTableQuery = '''
    CREATE TABLE $table (
      $colId TEXT PRIMARY KEY,
      $colAmount REAL NOT NULL,
      $colTitle TEXT NOT NULL,
      $colCategory TEXT NOT NULL,
      $colType TEXT NOT NULL,
      $colDate INTEGER NOT NULL,
      $colDescription TEXT,
      $colCreatedAt INTEGER NOT NULL
    )
  ''';

  /// تبدیل موجودیت دامنه به Map جهت ذخیره در SQLite
  static Map<String, dynamic> toMap(TransactionEntity entity) {
    return {
      colId: entity.id,
      colAmount: entity.amount,
      colTitle: entity.title,
      colCategory: entity.category,
      colType: entity.type.name,
      colDate: entity.date.millisecondsSinceEpoch,
      colDescription: entity.description,
      colCreatedAt: entity.createdAt.millisecondsSinceEpoch,
    };
  }

  /// تبدیل ردیف SQLite به موجودیت دامنه
  static TransactionEntity fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map[colId] as String,
      amount: (map[colAmount] as num).toDouble(),
      title: map[colTitle] as String,
      category: map[colCategory] as String,
      type: (map[colType] as String) == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      date: DateTime.fromMillisecondsSinceEpoch(map[colDate] as int),
      description: map[colDescription] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map[colCreatedAt] as int),
    );
  }

  /// تبدیل موجودیت به JSON ساده برای تهیه نسخه پشتیبان
  static Map<String, dynamic> toJson(TransactionEntity entity) {
    return {
      colId: entity.id,
      colAmount: entity.amount,
      colTitle: entity.title,
      colCategory: entity.category,
      colType: entity.type.name,
      colDate: entity.date.toIso8601String(),
      colDescription: entity.description,
      colCreatedAt: entity.createdAt.toIso8601String(),
    };
  }

  /// ساخت موجودیت از JSON (هنگام بازیابی نسخه پشتیبان)
  static TransactionEntity fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json[colId] as String,
      amount: (json[colAmount] as num).toDouble(),
      title: json[colTitle] as String,
      category: json[colCategory] as String,
      type: (json[colType] as String) == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      date: DateTime.parse(json[colDate] as String),
      description: json[colDescription] as String?,
      createdAt: DateTime.parse(json[colCreatedAt] as String),
    );
  }
}
