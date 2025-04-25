import 'package:diary/components/todo/action_button.dart';
import 'package:diary/components/todo/schedule_card.dart';
import 'package:diary/components/todo/task_input_card.dart';
import 'package:diary/components/todo/todo_date_time_pickers.dart';
import 'package:diary/components/todo/todo_feedback.dart';
import 'package:diary/services/todo_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TodoService _todoService = TodoService();
  bool _isLoading = false; // Add loading state flag

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'New Task',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.7)
                  : theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task input card
              TaskInputCard(
                controller: _titleController,
                isDark: isDark,
                theme: theme,
              ),

              const SizedBox(height: 24),

              // Schedule card
              ScheduleCard(
                theme: theme,
                isDark: isDark,
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                onPickDate: _pickDate,
                onPickTime: _pickTime,
              ),

              const SizedBox(height: 12),

              // Hint about categories
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: theme.colorScheme.primary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Categories will be automatically assigned based on your task description',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ActionButton(
        label: 'Create Task',
        icon: Icons.add_task_rounded,
        onPressed: _saveTodo,
        theme: theme,
        isLoading: _isLoading, // Pass the loading state to the button
      ),
    );
  }

  void _pickDate() async {
    final date = await TodoDateTimePickers.pickDate(
      context,
      initialDate: _selectedDate,
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _pickTime() async {
    final time = await TodoDateTimePickers.pickTime(
      context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _saveTodo() {
    // Prevent multiple submissions
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      TodoFeedback.showErrorMessage(context, 'Please enter your task');
      return;
    }

    // Set loading state to true before API call
    setState(() {
      _isLoading = true;
    });

    _todoService
        .addTodo(
      title: _titleController.text.trim(),
      date: _selectedDate == null
          ? ''
          : DateFormat('MMM dd, yyyy').format(_selectedDate!),
      time: _selectedTime == null ? '' : _selectedTime!.format(context),
    )
        .then((_) {
      TodoFeedback.showSuccessMessage(context, 'Task added successfully');
      Navigator.pop(context);
    }).catchError((error) {
      TodoFeedback.showErrorMessage(context, 'Failed to add task');
    }).whenComplete(() {
      // Reset loading state if the operation completes without navigation
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
