import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../widgets/task_card.dart';
import '../../tasks/tasks_screen.dart';
import '../../../services/task_storage_service.dart';
import '../../../models/task_model.dart';

class UpcomingTasksWidget extends StatefulWidget {
  const UpcomingTasksWidget({super.key});

  @override
  State<UpcomingTasksWidget> createState() => _UpcomingTasksWidgetState();
}

class _UpcomingTasksWidgetState extends State<UpcomingTasksWidget> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await TaskStorageService.loadTasks();

      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      final upcomingTasks = tasks.where((task) => !task.isCompleted).toList();

      setState(() {
        _tasks = upcomingTasks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Upcoming Tasks'),
        const SizedBox(height: 8),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _tasks.isEmpty
            ? _buildEmptyState()
            : _buildTaskList(),
      ],
    );
  }

  Widget _buildTaskList() {
    final tasksToShow = _tasks.take(2).toList();

    return Column(
      children: tasksToShow.map((task) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskCard(
            title: task.title,
            description: task.description,
            date: _formatDueDate(task.dueDate),
            isCompleted: task.isCompleted,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            HugeIcons.strokeRoundedCheckList,
            size: 48,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming tasks',
            style: TextStyle(
              color: Theme.of(context).disabledColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Build Section Header
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TasksScreen(),
              ),
            ).then((_) {
              _loadTasks();
            });
          },
          icon: const Icon(HugeIcons.strokeRoundedLinkCircle02, size: 16),
          label: const Text('View All'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
          ),
        ),
      ],
    );
  }
}