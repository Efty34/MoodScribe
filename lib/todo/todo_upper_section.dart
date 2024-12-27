import 'package:animations/animations.dart';
import 'package:diary/pages/add_todo_page.dart';
import 'package:flutter/material.dart';

class TodoUpperSection extends StatelessWidget {
  const TodoUpperSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              // CircularProgressIndicator(),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Tasks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('1 of 2 tasks'),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AddTodoPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
