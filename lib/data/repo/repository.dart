import 'package:todo/data/source/source.dart';

class Repository<T> implements DataSource {
  final DataSource<T> dataSource;

  Repository({required this.dataSource});
  @override
  Future<dynamic> createOrUpdate(data) {
    return dataSource.createOrUpdate(data);
  }

  @override
  Future<void> delete(data) {
    return dataSource.delete(data);
  }

  @override
  Future<void> deleteAll() {
    return dataSource.deleteAll();
  }

  @override
  Future<void> deleteById(id) {
    return deleteById(id);
  }

  @override
  Future<dynamic> findById(id) {
    return dataSource.findById(id);
  }

  @override
  Future<List<dynamic>> getAll({String? searchKeyword}) {
    return dataSource.getAll();
  }
}
