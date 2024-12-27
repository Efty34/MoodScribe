import 'package:diary/todo/todo_builder.dart';
import 'package:diary/todo/todo_upper_section.dart';
import 'package:flutter/material.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: const Column(
        children: [
          TodoUpperSection(),
          Expanded(
            child: TodoBuilder(),
          ),
        ],
      ),
    );
  }
}
