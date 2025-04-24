import 'package:diary/services/todo_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TodoDialogs {
  static void showUpdateSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Task updated successfully',
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
  }

  static Future<bool> showDeleteConfirmation(
      BuildContext context, String todoId) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Delete Task',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            content: Text(
              'Are you sure you want to delete this task?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red[400],
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  static Future<bool?> showUpdateDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final TodoService todoService = TodoService();
    final titleController = TextEditingController(text: data['title']);
    DateTime? selectedDate;
    if (data['date'] != null && data['date'].toString().isNotEmpty) {
      try {
        selectedDate = DateFormat('MMM dd, yyyy').parse(data['date']);
      } catch (e) {
        try {
          selectedDate = DateTime.parse(data['date']);
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
    }

    TimeOfDay? selectedTime;
    if (data['time'] != null && data['time'].toString().isNotEmpty) {
      try {
        selectedTime =
            TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(data['time']));
      } catch (e) {
        print('Error parsing time: $e');
      }
    }

    // Category will be determined automatically by Gemini API

    return await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Update Task',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                // Category will be determined automatically by Gemini API
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedDate == null
                                    ? 'Select Date'
                                    : DateFormat('MMM dd, yyyy')
                                        .format(selectedDate!),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: selectedDate == null
                                      ? Colors.grey[500]
                                      : Colors.grey[800],
                                ),
                              ),
                              if (selectedDate != null) ...[
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedDate = null;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              selectedTime = time;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedTime == null
                                    ? 'Select Time'
                                    : selectedTime!.format(context),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: selectedTime == null
                                      ? Colors.grey[500]
                                      : Colors.grey[800],
                                ),
                              ),
                              if (selectedTime != null) ...[
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedTime = null;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Task title cannot be empty',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: Colors.red[400],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  return;
                }

                await todoService.updateTodo(
                  todoId: docId,
                  title: titleController.text.trim(),
                  date: selectedDate == null
                      ? ''
                      : DateFormat('MMM dd, yyyy').format(selectedDate!),
                  time:
                      selectedTime == null ? '' : selectedTime!.format(context),
                  // Category will be determined by Gemini API
                );

                if (context.mounted) {
                  showUpdateSuccessMessage(context);
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(
                'Update',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
