import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/taskModel.dart';
import 'task_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Task Manager',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: taskProvider.tasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.hourglass_empty,
              size: 100,
              color: Colors.black26,
            ),
            const SizedBox(height: 20),
            const Text(
              "No tasks yet!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add a task to get started!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black38,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _showAddTaskModal(context),
              child: const Text(
                "Add Task",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      )
          : AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        initialItemCount: taskProvider.tasks.length,
        itemBuilder: (context, index, animation) {
          final task = taskProvider.tasks[index];
          return SizeTransition(
            sizeFactor: animation,
            child: _buildTaskTile(context, taskProvider, task, index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
        onPressed: () => _showAddTaskModal(context),
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, TaskProvider provider, Task task, int index) {
    return GestureDetector(
      onTap: () {
        provider.toggleTaskStatus(index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: task.isCompleted ? Colors.green.withOpacity(0.2) : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width:25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? Colors.green : Colors.black26,
                  width: 2,
                ),
                color: task.isCompleted ? Colors.green : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 24, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: task.isCompleted ? Colors.black45 : Colors.black87,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                _deleteTask(context, provider, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskModal(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final TextEditingController taskController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              TextField(
                controller: taskController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter Task Title...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  final text = taskController.text.trim();
                  if (text.isNotEmpty) {
                    taskProvider.addTask(text);
                    _listKey.currentState?.insertItem(taskProvider.tasks.length - 1);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  'Add Task',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteTask(BuildContext context, TaskProvider provider, int index) {
    final removedTask = provider.tasks[index];
    provider.deleteTask(index);
    _listKey.currentState?.removeItem(
      index,
          (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: _buildTaskTile(context, provider, removedTask, index),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }
}
