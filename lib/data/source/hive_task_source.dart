import 'package:hive_flutter/adapters.dart';
import 'package:todo/data/data.dart';
import 'package:todo/data/source/source.dart';

class HiveTaskDataSource implements DataSource<Task> {
  final Box<Task> box;

  HiveTaskDataSource({required this.box});
  @override
  Future<Task> createOrUpdate(Task data) async {
    if (data.isInBox) {
      data.save();
    } else {
      data.id = await box.add(data);
    }
    return data;
  }

  @override
  Future<void> delete(Task data) async {
    return data.delete();
  }

  @override
  Future<void> deleteAll() async {
    box.clear();
  }

  @override
  Future<void> deleteById(id) {
    return box.delete(id);
  }

  @override
  Future<Task> findById(id) async {
    return box.values.firstWhere((task) => task.id == id);
  }

  @override
  Future<List<Task>> getAll({String? searchKeyword}) async {
    if (searchKeyword != null) {
      return box.values
          .where((task) => task.name.contains(searchKeyword))
          .toList();
    } else {
      return box.values.toList();
    }
  }

  @override
  Future<int> getLengthOfData() async {
    return box.values.length;
  }
}
