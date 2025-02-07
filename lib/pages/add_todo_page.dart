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
  // String? _category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add New Task',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.grey[800],
            size: 22,
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
              // Todo Field
              Text(
                'What to do?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.poppins(),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Enter your task',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your task';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Date & Time Section
              Text(
                'Schedule',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.blue[700], size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(_selectedDate!),
                              style: GoogleFonts.poppins(
                                color: _selectedDate == null
                                    ? Colors.grey[500]
                                    : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time,
                                color: Colors.blue[700], size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _selectedTime == null
                                  ? 'Select Time'
                                  : _selectedTime!.format(context),
                              style: GoogleFonts.poppins(
                                color: _selectedTime == null
                                    ? Colors.grey[500]
                                    : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              offset: const Offset(0, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _saveTodo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Add Task',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  // void _showCategorySnackbar(String category) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           Icon(
  //             _getCategoryIcon(category),
  //             color: Colors.white,
  //             size: 20,
  //           ),
  //           const SizedBox(width: 12),
  //           Text(
  //             'Category: ${category.toUpperCase()}',
  //             style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ],
  //       ),
  //       backgroundColor: Colors.grey[800],
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       duration: const Duration(seconds: 2),
  //       elevation: 1,
  //     ),
  //   );
  // }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'submission':
        return Icons.assignment_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'groceries':
        return Icons.shopping_cart_outlined;
      case 'fitness':
        return Icons.fitness_center_outlined;
      case 'self-care':
        return Icons.spa_outlined;
      case 'social':
        return Icons.people_outline;
      case 'medicine':
        return Icons.medical_services_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  void _saveTodo() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your task',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 3),
          elevation: 1,
        ),
      );
      return;
    }

    _todoService
        .addTodo(
      title: _titleController.text.trim(),
      date: _selectedDate == null
          ? ''
          : DateFormat('MMM dd, yyyy').format(_selectedDate!),
      time: _selectedTime == null ? '' : _selectedTime!.format(context),
    )
        .then((_) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Task added successfully',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 2),
          elevation: 1,
        ),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }).catchError((error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add task',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
