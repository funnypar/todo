import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:todo/data/data.dart';
import 'package:todo/data/repo/repository.dart';

part 'task_list_event.dart';
part 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final Repository<Task> repository;
  TaskListBloc({required this.repository}) : super(TaskListInitial()) {
    on<TaskListEvent>((event, emit) async {
      if (event is TaskListStarted || event is TaskListSearch) {
        final String searchTerm;
        emit(TaskListLoading());
        // Here I know that user is watching the home screen
        if (event is TaskListSearch) {
          searchTerm = event.searchTerm;
        } else {
          searchTerm = '';
        }

        try {
          final tasks = await repository.getAll(searchKeyword: searchTerm);

          if (tasks.isNotEmpty) {
            emit(TaskListSuccess(items: tasks));
          } else {
            emit(TaskListEmpty());
          }
        } catch (e) {
          emit(TaskListError(errorMessage: 'Something went wrong!'));
        }
      } else if (event is TaskListDeleteAll) {
        await repository.deleteAll();
        emit(TaskListEmpty());
      }
    });
  }
}
