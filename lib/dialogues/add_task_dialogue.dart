import 'package:flutter/material.dart';

class AddTaskDialogue extends StatefulWidget {
  const AddTaskDialogue({
    super.key,
    required this.addTaskCallback,
    required this.checkTaskExistenceCallback,
  });
  @override
  State<AddTaskDialogue> createState() => _AddTaskDialogueState();

  final void Function(String) addTaskCallback;
  final bool Function(String) checkTaskExistenceCallback;
}

class _AddTaskDialogueState extends State<AddTaskDialogue> {
  String? errorText;
  TextEditingController taskNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      content: SizedBox(
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Add Task",
              style: TextStyle(
                fontSize: 30,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              controller: taskNameController,
              keyboardType: TextInputType.name,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                label: const Text("New Task"),
                // labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                errorText: errorText,
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              onSubmitted: (x) {
                addTask();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: addTask,
              child: const Text("Add"),
            )
          ],
        ),
      ),
    );
  }

  void addTask() {
    if (!widget.checkTaskExistenceCallback(taskNameController.text)) {
      if (taskNameController.text != '') {
        if (!taskNameController.text.contains("|") &&
            !taskNameController.text.contains("^")) {
          widget.addTaskCallback(taskNameController.text);
          errorText = null;
          Navigator.pop(context);
        } else {
          setState(() {
            errorText = "Task name cannot contain '|' or '^'";
          });
        }
      }
    } else {
      setState(() {
        errorText = "Task Already Exists";
      });
    }
  }
}
