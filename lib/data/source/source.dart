import 'package:todo/data/data.dart';

abstract class DataSource<T> {
  Future<List<Task>> getAll({String? searchKeyword});
  Future<T> findById(dynamic id);
  Future<void> deleteAll();
  Future<void> delete(T data);
  Future<void> deleteById(dynamic id);
  Future<T> createOrUpdate(T data);
  Future<int> getLengthOfData();
}
