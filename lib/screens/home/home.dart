import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:todo/data/data.dart';
import 'package:todo/data/repo/repository.dart';
import 'package:todo/main.dart';
import 'package:todo/screens/edit/edit.dart';
import 'package:todo/screens/home/bloc/task_list_bloc.dart';
import 'package:todo/widgets.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final ValueNotifier<String> searchKeywordNotifier = ValueNotifier('');

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(task: Task()),
            ),
          );
        },
        label: Row(
          children: [
            Text('Add New Task'),
            SizedBox(width: 8),
            Icon(CupertinoIcons.plus),
          ],
        ),
      ),
      body: BlocProvider<TaskListBloc>(
        create: (context) =>
            TaskListBloc(repository: context.read<Repository<Task>>()),
        child: Builder(
          builder: (context) {
            return SafeArea(
              child: Column(
                children: [
                  Container(
                    height: 102,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeData.colorScheme.primary,
                          themeData.colorScheme.primaryContainer,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'To Do List',
                                style: themeData.textTheme.titleLarge!.apply(
                                  color: themeData.colorScheme.onPrimary,
                                ),
                              ),
                              Icon(
                                CupertinoIcons.share,
                                color: themeData.colorScheme.onPrimary,
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Container(
                            height: 38,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(19),
                              color: themeData.colorScheme.onPrimary,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: controller,
                              onChanged: (value) => context
                                  .read<TaskListBloc>()
                                  .add(TaskListSearch(searchTerm: value)),
                              decoration: InputDecoration(
                                prefixIcon: Icon(CupertinoIcons.search),
                                hintText: 'Search Tasks...',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Consumer<Repository<Task>>(
                      builder: (context, repository, child) {
                        context.read<TaskListBloc>().add(TaskListStarted());
                        return BlocBuilder<TaskListBloc, TaskListState>(
                          builder: (context, state) {
                            if (state is TaskListSuccess) {
                              return TaskList(
                                items: state.items,
                                themeData: themeData,
                              );
                            } else if (state is TaskListEmpty) {
                              return EmptyState();
                            } else if (state is TaskListLoading ||
                                state is TaskListInitial) {
                              return Center(child: CircularProgressIndicator());
                            } else if (state is TaskListError) {
                              return Center(child: Text(state.errorMessage));
                            } else {
                              throw Exception('State is not valid');
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList({super.key, required this.items, required this.themeData});

  final List<Task> items;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    final taskRepo = Provider.of<Repository<Task>>(context);
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: themeData.textTheme.titleLarge!.apply(
                        fontSizeFactor: 0.9,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      width: 70,
                      height: 3,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ],
                ),
                // Inside TaskList's build method:
                MaterialButton(
                  color: const Color(0xffEAEFF5),
                  textColor: secondaryTextColor,
                  elevation: 0,
                  onPressed: () {
                    // This will now work in 1 click because the BLoC isn't being
                    // interrupted by a "Started" event from the HomeScreen's Consumer.
                    context.read<TaskListBloc>().add(TaskListDeleteAll());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delete All',
                        style: TextStyle(
                          // Use the items list length instead of a FutureBuilder
                          color: items.isNotEmpty ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.delete_solid,
                        color: items.isNotEmpty
                            ? Colors.redAccent
                            : Colors.grey,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          final Task task = items[index - 1];
          return TaskItem(task: task);
        }
      },
    );
  }
}

class TaskItem extends StatefulWidget {
  const TaskItem({super.key, required this.task});

  final Task task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Color priorityColor;
    final taskRepo = Provider.of<Repository<Task>>(context);

    switch (widget.task.priority) {
      case Priority.low:
        priorityColor = lowPriority;
        break;
      case Priority.normal:
        priorityColor = normalPriority;
        break;
      case Priority.high:
        priorityColor = hightPriority;
        break;
    }
    return InkWell(
      onTap: () => setState(() {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditTaskScreen(task: widget.task),
          ),
        );
      }),
      onLongPress: () {
        taskRepo.delete(widget.task);
      },
      child: Container(
        height: 84,
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: themeData.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ],
        ),
        child: Row(
          children: [
            MyCheckBox(
              value: widget.task.isCompleted,
              onTap: () => setState(() {
                widget.task.isCompleted = !widget.task.isCompleted;
              }),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.task.name,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 20,
                  decoration: widget.task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
            Container(
              width: 5,
              height: 84,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
