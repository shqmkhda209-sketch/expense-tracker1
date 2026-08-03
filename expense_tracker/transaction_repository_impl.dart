import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/database_helper.dart';
import '../models/transaction_model.dart';

/// پیاده‌سازی واقعی ریپازیتوری تراکنش با SQLite (sqflite)
class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseHelper _dbHelper;

  TransactionRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<TransactionEntity>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      TransactionModel.table,
      orderBy: '${TransactionModel.colDate} DESC, ${TransactionModel.colCreatedAt} DESC',
    );
    return rows.map(TransactionModel.fromMap).toList();
  }

  @override
  Future<TransactionEntity?> getById(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      TransactionModel.table,
      where: '${TransactionModel.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TransactionModel.fromMap(rows.first);
  }

  @override
  Future<void> add(TransactionEntity transaction) async {
    final db = await _dbHelper.database;
    await db.insert(TransactionModel.table, TransactionModel.toMap(transaction));
  }

  @override
  Future<void> update(TransactionEntity transaction) async {
    final db = await _dbHelper.database;
    await db.update(
      TransactionModel.table,
      TransactionModel.toMap(transaction),
      where: '${TransactionModel.colId} = ?',
      whereArgs: [transaction.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      TransactionModel.table,
      where: '${TransactionModel.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete(TransactionModel.table);
  }

  @override
  Future<void> insertBatch(List<TransactionEntity> transactions) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final t in transactions) {
      batch.insert(TransactionModel.table, TransactionModel.toMap(t));
    }
    await batch.commit(noResult: true);
  }
}
