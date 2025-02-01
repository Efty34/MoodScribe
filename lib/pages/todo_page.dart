import 'package:diary/todo/todo_builder.dart';
import 'package:diary/todo/todo_upper_section.dart';
import 'package:diary/utils/search_state.dart';
import 'package:flutter/material.dart';

class TodoPage extends StatelessWidget {
  final SearchState searchState;

  const TodoPage({
    super.key,
    required this.searchState,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const TodoUpperSection(),
            Expanded(
              child: TodoBuilder(searchState: searchState),
            ),
          ],
        ),
      ),
    );
  }
}
