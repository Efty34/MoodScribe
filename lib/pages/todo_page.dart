import 'package:diary/todo/todo_builder.dart';
import 'package:diary/todo/todo_upper_section.dart';
import 'package:flutter/material.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TodoUpperSection(),
            Expanded(
              child: TodoBuilder(),
            ),
          ],
        ),
      ),
    );
  }
}
