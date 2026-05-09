import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/data/data.dart';
import 'package:todo/data/repo/repository.dart';
import 'package:todo/main.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key, required this.task});

  final Task task;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.task.name,
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
        backgroundColor: themeData.colorScheme.surface,
        foregroundColor: themeData.colorScheme.onSurface,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.task.name = _controller.text;
          final taskRepo = Provider.of<Repository<Task>>(
            context,
            listen: false,
          );
          taskRepo.createOrUpdate(widget.task);
          Navigator.of(context).pop();
        },
        label: Row(
          children: [
            Text('Save Cahnges'),
            SizedBox(width: 8),
            Icon(CupertinoIcons.check_mark_circled, size: 22),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 1,
                  child: PeriorityRadioBox(
                    label: 'High',
                    iconColor: hightPriority,
                    isSelected: widget.task.priority == Priority.high,
                    onTap: () => setState(() {
                      widget.task.priority = Priority.high;
                    }),
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: PeriorityRadioBox(
                    label: 'Normal',
                    iconColor: normalPriority,
                    isSelected: widget.task.priority == Priority.normal,
                    onTap: () => setState(() {
                      widget.task.priority = Priority.normal;
                    }),
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: PeriorityRadioBox(
                    label: 'Low',
                    iconColor: lowPriority,
                    isSelected: widget.task.priority == Priority.low,
                    onTap: () => setState(() {
                      widget.task.priority = Priority.low;
                    }),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                label: Text('Add a task for today...'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PeriorityRadioBox extends StatelessWidget {
  final String label;
  final Color iconColor;
  final bool isSelected;
  final GestureTapCallback onTap;

  const PeriorityRadioBox({
    super.key,
    required this.label,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            width: 2,
            color: secondaryTextColor.withValues(alpha: 0.2),
          ),
        ),
        child: Stack(
          children: [
            Center(child: Text(label)),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: PeriorityCheckBox(value: isSelected, color: iconColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PeriorityCheckBox extends StatelessWidget {
  final bool value;
  final Color color;

  const PeriorityCheckBox({
    super.key,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
      ),
      child: value
          ? Icon(
              CupertinoIcons.check_mark,
              color: themeData.colorScheme.onSecondary,
              size: 12,
            )
          : null,
    );
  }
}
