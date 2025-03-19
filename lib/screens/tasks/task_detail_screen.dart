import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';
import 'add_task_screen.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  void _toggleTaskCompletion() {
    setState(() {
      _task = _task.copyWith(isCompleted: !_task.isCompleted);
    });
  }

  void _editTask() async {
    final updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(task: _task),
      ),
    );

    if (updatedTask != null) {
      setState(() {
        _task = updatedTask;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task title and completion status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _task.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        decoration: _task.isCompleted ? TextDecoration.lineThrough : null,
                        color: _task.isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  Switch(
                    value: _task.isCompleted,
                    onChanged: (value) {
                      _toggleTaskCompletion();
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category and priority
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _task.category,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _task.priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag,
                          size: 16,
                          color: _task.priorityColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_task.priorityText} Priority',
                          style: TextStyle(
                            color: _task.priorityColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Due date
              _buildDetailItem(
                icon: Icons.calendar_today,
                title: 'Due Date',
                value: DateFormat('EEEE, MMMM d, yyyy').format(_task.dueDate),
                color: _task.isOverdue ? Colors.red : null,
              ),

              // Due time
              _buildDetailItem(
                icon: Icons.access_time,
                title: 'Due Time',
                value: DateFormat('h:mm a').format(_task.dueDate),
                color: _task.isOverdue ? Colors.red : null,
              ),

              // Status
              _buildDetailItem(
                icon: _task.isCompleted ? Icons.check_circle : _task.isOverdue ? Icons.warning : Icons.pending,
                title: 'Status',
                value: _task.isCompleted
                    ? 'Completed'
                    : _task.isOverdue
                    ? 'Overdue'
                    : 'Pending',
                color: _task.isCompleted
                    ? Colors.green
                    : _task.isOverdue
                    ? Colors.red
                    : Colors.orange,
              ),

              const SizedBox(height: 24),

              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _task.description,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleTaskCompletion,
                      icon: Icon(
                        _task.isCompleted ? Icons.refresh : Icons.check_circle,
                      ),
                      label: Text(
                        _task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color ?? Colors.grey.shade700,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: color ?? Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}