import 'package:flutter/widgets.dart';
import 'package:todo/data/data.dart';
import 'package:todo/data/source/source.dart';

class Repository<T> extends ChangeNotifier implements DataSource {
  final DataSource<T> dataSource;

  Repository({required this.dataSource});
  @override
  Future<dynamic> createOrUpdate(data) async {
    final T result = await dataSource.createOrUpdate(data);
    notifyListeners();
    return result;
  }

  @override
  Future<void> delete(data) async {
    dataSource.delete(data);
    notifyListeners();
  }

  @override
  Future<void> deleteAll() async {
    dataSource.deleteAll();
    notifyListeners();
  }

  @override
  Future<void> deleteById(id) async {
    dataSource.deleteById(id);
    notifyListeners();
  }

  @override
  Future<dynamic> findById(id) {
    return dataSource.findById(id);
  }

  @override
  Future<List<Task>> getAll({String? searchKeyword}) {
    return dataSource.getAll(searchKeyword: searchKeyword);
  }

  @override
  Future<int> getLengthOfData() {
    return dataSource.getLengthOfData();
  }
}
