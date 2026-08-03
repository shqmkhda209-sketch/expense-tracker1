import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';

/// مسئول ایجاد و مدیریت اتصال به پایگاه داده SQLite محلی.
/// از الگوی Singleton استفاده می‌شود تا فقط یک اتصال باز باشد
/// و عملکرد حتی با تعداد زیاد تراکنش (مثلاً ۵۰ هزار رکورد) روان بماند.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'expense_tracker.db';
  static const int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute(TransactionModel.createTableQuery);
        // ایندکس روی تاریخ و دسته‌بندی برای سرعت بخشیدن به فیلتر/گزارش‌ها
        await db.execute(
          'CREATE INDEX idx_transactions_date ON ${TransactionModel.table} (${TransactionModel.colDate})',
        );
        await db.execute(
          'CREATE INDEX idx_transactions_type ON ${TransactionModel.table} (${TransactionModel.colType})',
        );
      },
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
