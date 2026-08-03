import '../entities/transaction_entity.dart';

/// قرارداد انتزاعی ریپازیتوری تراکنش‌ها.
/// لایه‌ی presentation فقط با این اینترفیس کار می‌کند، نه با جزئیات دیتابیس.
abstract class TransactionRepository {
  Future<List<TransactionEntity>> getAll();
  Future<TransactionEntity?> getById(String id);
  Future<void> add(TransactionEntity transaction);
  Future<void> update(TransactionEntity transaction);
  Future<void> delete(String id);
  Future<void> deleteAll();
  Future<void> insertBatch(List<TransactionEntity> transactions);
}
