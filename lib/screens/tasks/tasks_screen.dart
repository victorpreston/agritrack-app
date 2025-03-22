import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../models/task_model.dart';
import '../../services/task_storage_service.dart';
import '../../theme/app_theme.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Task> tasks = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    final loadedTasks = await TaskStorageService.loadTasks();

    setState(() {
      tasks = loadedTasks;
      _isLoading = false;
    });
  }

  Future<void> _saveTasks() async {
    await TaskStorageService.saveTasks(tasks);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addNewTask() async {
    final newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );

    if (newTask != null) {
      setState(() {
        tasks.add(newTask);
      });
      await _saveTasks();
    }
  }

  void _toggleTaskCompletion(String taskId) async {
    setState(() {
      final taskIndex = tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        tasks[taskIndex] = tasks[taskIndex].copyWith(
          isCompleted: !tasks[taskIndex].isCompleted,
        );
      }
    });

    await _saveTasks();
  }

  void _deleteTask(String taskId) async {
    setState(() {
      tasks.removeWhere((task) => task.id == taskId);
    });

    await _saveTasks();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _updateTask(Task updatedTask) async {
    setState(() {
      final index = tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
    });

    await _saveTasks();
  }

  List<Task> _getFilteredTasks() {
    switch (_tabController.index) {
      case 0: // All
        return tasks;
      case 1: // Upcoming
        return tasks.where((task) => !task.isCompleted).toList();
      case 2: // Completed
        return tasks.where((task) => task.isCompleted).toList();
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          onTap: (index) {
            setState(() {});
          },
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  ...taskCategories.map((category) => _buildFilterChip(category)),
                ],
              ),
            ),
          ),

          // Tasks list
          Expanded(
            child: _getFilteredTasks().isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _getFilteredTasks().length,
              itemBuilder: (context, index) {
                final task = _getFilteredTasks()[index];
                if (_selectedFilter == 'All' || task.category == _selectedFilter) {
                  return _buildTaskCard(task);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String category) {
    final isSelected = category == _selectedFilter;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilter = category;
            });
          }
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: task.isOverdue
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                task: task,
                onTaskUpdated: _updateTask,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        _toggleTaskCompletion(task.id);
                      },
                      activeColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Task details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Colors.grey : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: task.isOverdue ? Colors.red : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d, yyyy').format(task.dueDate),
                              style: TextStyle(
                                color: task.isOverdue ? Colors.red : Colors.grey.shade600,
                                fontWeight: task.isOverdue ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: task.priorityColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    HugeIcons.strokeRoundedNoteDone,
                                    size: 14,
                                    color: task.priorityColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.priorityText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: task.priorityColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteTask(task.id);
                      } else if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailScreen(
                              task: task,
                              onTaskUpdated: _updateTask,
                            ),
                          ),
                        );
                      } else if (value == 'toggle') {
                        _toggleTaskCompletion(task.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              task.isCompleted ? Icons.refresh : Icons.check_circle,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(task.isCompleted ? 'Mark as incomplete' : 'Mark as complete'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Category chip
              Padding(
                padding: const EdgeInsets.only(left: 40.0, top: 8.0),
                child: Chip(
                  label: Text(
                    task.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_tabController.index) {
      case 1:
        message = 'No upcoming tasks';
        icon = Icons.event_available;
        break;
      case 2:
        message = 'No completed tasks yet';
        icon = Icons.check_circle_outline;
        break;
      default:
        message = 'No tasks found';
        icon = Icons.assignment_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          if (_tabController.index != 2)
            ElevatedButton.icon(
              onPressed: _addNewTask,
              icon: const Icon(Icons.add),
              label: const Text('Add New Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}