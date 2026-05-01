import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo/data.dart';

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
        textTheme: GoogleFonts.poppinsTextTheme(TextTheme()),
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
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => EditTaskScreen()));
        },
        label: Text('Add New Task'),
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
                        return Row(
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
                        );
                      } else {
                        final Task task = box.values.toList()[index - 1];
                        return Container(child: Text(task.name));
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

class EditTaskScreen extends StatelessWidget {
  EditTaskScreen({super.key});
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Task')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final task = Task();
          task.name = _controller.text;
          if (task.isInBox) {
            // Update
            task.save();
          } else {
            // Save New Item
            final Box<Task> box = Hive.box(taskBoxName);
            box.add(task);
          }
          // Close the page
          Navigator.of(context).pop();
        },
        label: Text('Save Cahnges'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(label: Text('Add a task for today...')),
          ),
        ],
      ),
    );
  }
}
