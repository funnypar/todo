import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo/data.dart';
import 'package:todo/edit.dart';

const taskBoxName = 'tasks';
Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: primaryColor),
  );
  runApp(const MyApp());
}

final Color primaryColor = Color(0xff794cFF);
final Color secondaryTextColor = Color(0xffAFBED0);
final Color normalPriority = Color(0xffF09819);
final Color lowPriority = Color(0xff3BE1f1);
final Color hightPriority = primaryColor;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = Color(0xff1D2830);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: secondaryTextColor),
          iconColor: secondaryTextColor,
          border: InputBorder.none,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          TextTheme(titleLarge: TextStyle(fontWeight: FontWeight.bold)),
        ),
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          primaryContainer: Color(0xfff5c0aff),
          surface: Color(0xffff3f5f8),
          onSurface: primaryTextColor,
          onSurfaceVariant: primaryTextColor,
          secondary: primaryColor,
          onSecondary: Colors.white,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>(taskBoxName);
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
      body: SafeArea(
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
              child: ValueListenableBuilder<Box<Task>>(
                valueListenable: box.listenable(),
                builder: (context, box, child) {
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: box.values.length + 1,
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
                                    style: themeData.textTheme.titleLarge!
                                        .apply(fontSizeFactor: 0.9),
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
                              MaterialButton(
                                color: Color(0xffEAEFF5),
                                textColor: secondaryTextColor,
                                elevation: 0,
                                onPressed: () {},
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Delete All'),
                                    SizedBox(width: 4),
                                    Icon(CupertinoIcons.delete_solid, size: 18),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        final Task task = box.values.toList()[index - 1];
                        return TaskItem(task: task);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
        widget.task.isCompleted = !widget.task.isCompleted;
      }),
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
            MyCheckBox(value: widget.task.isCompleted),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.task.name,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 24,
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

class MyCheckBox extends StatelessWidget {
  final bool value;

  const MyCheckBox({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: !value ? Border.all(color: secondaryTextColor, width: 2) : null,
        color: value ? primaryColor : null,
      ),
      child: value
          ? Icon(
              CupertinoIcons.check_mark,
              color: themeData.colorScheme.onSecondary,
              size: 14,
            )
          : null,
    );
  }
}
