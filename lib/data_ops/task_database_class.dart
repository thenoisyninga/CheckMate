import 'package:hive_flutter/hive_flutter.dart';
import 'package:sarims_todo_app/data_ops/encryption.dart';
import 'package:sarims_todo_app/data_ops/task_data_from_cloud.dart';
import 'package:sarims_todo_app/data_ops/user_session_local_ops.dart';

class TaskDatabase {
  List<List<dynamic>> taskList = [];
  final _myBox = Hive.box("TASKS_LOCAL_DATABASE");

  void createDefaultData() {
    print("Creating default data");
    taskList = [
      ["Clean Car", true],
      ["Kill Sarim", false],
      ["Hide Body", false],
      ["File Missing Person's Report", false],
    ];
  }

  bool loadData() {
    if (_myBox.get("TASKS_LIST") == null) {
      // Create defaults and save
      createDefaultData();
      saveData();
    } else {
      // fetch data from server
      List<String> combinedStringList = _myBox.get('TASKS_LIST');
      taskList = [];
      for (var element in combinedStringList) {
        List<dynamic> taskData = element.split("||");
        String taskName = taskData[0];
        bool completed = taskData[1] == "true";
        taskList.add([taskName, completed]);
      }
    }
    return true;
  }

  void saveData() {
    List<String> combinedStringList = [];
    for (var taskData in taskList) {
      List newTaskData = [taskData[0], ""];
      newTaskData[1] = taskData[1] ? "true" : "false";
      combinedStringList.add(newTaskData.join("||"));
    }

    _myBox.put("TASKS_LIST", combinedStringList);
    // uploadDataToServer();
  }

  void changeCompleteStatus(String taskName) {
    int index = taskList.indexWhere((taskData) => taskData[0] == taskName);
    taskList[index][1] = !taskList[index][1];
    saveData();
  }

  void addTask(String taskName) {
    taskList.insert(0, [taskName, false]);
    saveData();
  }

  void addTaskAtIndex(List task, int index) {
    taskList.insert(index, task);
    saveData();
  }

  bool checkTaskExistence(String taskName) {
    loadData();
    int index = taskList.indexWhere((element) => element[0] == taskName);
    return index != -1;
  }

  void deleteTask(String taskName) {
    taskList.removeWhere((element) => element[0] == taskName);
    saveData();
  }

  List deleteTaskAtIndex(int index) {
    saveData();
    return taskList.removeAt(index);
  }

  Future<bool> uploadDataToServer() async {
    List<String> combinedStringList = [];

    for (var taskData in taskList) {
      List newTaskData = [taskData[0], ""];
      newTaskData[1] = taskData[1] ? "true" : "false";
      combinedStringList.add(newTaskData.join("||"));
    }

    String taskDataString = combinedStringList.join("|||");
    if (getSessionEncryptionKey().isNotEmpty) {
      final encryptedData =
          encryptTaskData(taskDataString, getSessionEncryptionKey());
      return await uploadEncryptedDataToServer(encryptedData);
    } else {
      return false;
    }
  }

  Future<bool> getTaskDataFromServer() async {
    // Get Data
    final encryptedData = await fetchEncryptedDataFromServer();

    if (encryptedData.isNotEmpty && getSessionEncryptionKey().isNotEmpty) {
      if (encryptedData != "NULL") {
        // Decrypt Data
        final decryptedData =
            decryptTaskData(encryptedData, getSessionEncryptionKey());
        // Verify Decrypted Data
        if (verifyDecryptedData(decryptedData)) {
          // print(decryptedData);
          var combinedStringTaskData =
              extractTaskData(decryptedData).split("|||");
          taskList = [];

          for (var element in combinedStringTaskData) {
            List<dynamic> taskData = element.split("||");
            String taskName = taskData[0];
            bool completed = taskData[1] == "true";
            taskList.add([taskName, completed]);
          }
          saveData();
          return true;
        } else {
          return false;
        }
      } else {
        print("Creating new data for new user.");
        loadData();
        // return await uploadDataToServer();
        return true;
      }
    } else {
      return false;
    }
  }
}
