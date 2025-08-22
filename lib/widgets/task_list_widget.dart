import 'package:flutter/material.dart';

class TaskListWidget extends StatefulWidget {
  const TaskListWidget({super.key});

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  final List<Task> _tasks = [
    Task(id: '1', title: 'Review Flutter concepts', isCompleted: false),
    Task(id: '2', title: 'Complete math homework', isCompleted: true),
    Task(id: '3', title: 'Read chapter 5', isCompleted: false),
  ];

  final TextEditingController _taskController = TextEditingController();

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;

    setState(() {
      _tasks.add(
        Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _taskController.text.trim(),
          isCompleted: false,
        ),
      );
    });
    _taskController.clear();
  }

  void _toggleTask(String id) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == id);
      if (taskIndex != -1) {
        _tasks[taskIndex] = _tasks[taskIndex].copyWith(
          isCompleted: !_tasks[taskIndex].isCompleted,
        );
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🍉 Study Tasks',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Add task input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new study task...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                IconButton(
                  onPressed: _addTask,
                  icon: const Icon(
                    Icons.add_circle,
                    color: Color(0xFF4CAF50),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Task list
          Expanded(
            child: _tasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No tasks yet!\nAdd your first study task above.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () => _toggleTask(task.id),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: task.isCompleted
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey,
                                  width: 2,
                                ),
                                color: task.isCompleted
                                    ? const Color(0xFF4CAF50)
                                    : Colors.transparent,
                              ),
                              child: task.isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () => _deleteTask(task.id),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}

class Task {
  final String id;
  final String title;
  final bool isCompleted;

  Task({required this.id, required this.title, required this.isCompleted});

  Task copyWith({String? id, String? title, bool? isCompleted}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
