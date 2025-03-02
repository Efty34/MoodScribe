import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/pages/add_todo_page.dart';
import 'package:diary/services/todo_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoUpperSection extends StatefulWidget {
  final TabController tabController;

  const TodoUpperSection({
    super.key,
    required this.tabController,
  });

  @override
  State<TodoUpperSection> createState() => _TodoUpperSectionState();
}

class _TodoUpperSectionState extends State<TodoUpperSection> {
  final TodoService _todoService = TodoService();

  @override
  Widget build(BuildContext context) {
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

        return Column(
          children: [
            Padding(
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
                              fontSize: 20,
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
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue[200]!,
                  width: 1,
                ),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                controller: widget.tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(4),
                splashBorderRadius: BorderRadius.circular(8),
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[400]!,
                      Colors.blue[600]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                tabs: [
                  Tab(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: widget.tabController.index == 0 ? 1.0 : 0.8,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pending_actions_rounded,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('Pending'),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: widget.tabController.index == 1 ? 1.0 : 0.8,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt_rounded,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('Completed'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
