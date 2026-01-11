import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list_master/models/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Box? _box;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Todo List Master"), centerTitle: true),
      body: FutureBuilder(
        future: Hive.openBox('tasks_box'),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          _box = snapshot.data;
          var tasks = _box!.values.toList();
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, i) {
              var task = TaskModel.fromJson(tasks[i]);
              return ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                trailing: Checkbox(
                  value: task.isCompleted,
                  onChanged: (v) {
                    task.isCompleted = v!;
                    _box!.putAt(i, task.toJson());
                    setState(() {});
                  },
                ),
                onLongPress: () {
                  _box!.deleteAt(i);
                  setState(() {});
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog() {
    String newTask = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Task"),
        content: TextField(onChanged: (v) => newTask = v),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (newTask.isNotEmpty) {
                _box!.add(TaskModel(title: newTask).toJson());
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
