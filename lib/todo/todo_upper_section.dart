import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/pages/add_todo_page.dart';
import 'package:diary/services/todo_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoUpperSection extends StatelessWidget {
  const TodoUpperSection({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoService _todoService = TodoService();

    return StreamBuilder<QuerySnapshot>(
      stream: _todoService.getTodos(),
      builder: (context, snapshot) {
        int totalTasks = 0;
        int completedTasks = 0;

        if (snapshot.hasData) {
          totalTasks = snapshot.data!.docs.length;
          completedTasks = snapshot.data!.docs
              .where((doc) => (doc.data() as Map)['isDone'] == true)
              .length;
        }

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Tasks',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$completedTasks of $totalTasks tasks completed',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  FloatingActionButton(
                    onPressed: () => _showAddTodoPage(context),
                    backgroundColor: Colors.blue,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: totalTasks == 0 ? 0 : completedTasks / totalTasks,
                backgroundColor: Colors.blue[100],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue[700] ?? Colors.blue,
                ),
                borderRadius: BorderRadius.circular(10),
                minHeight: 10,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTodoPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTodoPage()),
    );
  }
}
