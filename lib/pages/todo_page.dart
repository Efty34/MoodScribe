import 'package:diary/todo/todo_builder.dart';
import 'package:diary/todo/todo_upper_section.dart';
import 'package:diary/utils/search_state.dart';
import 'package:flutter/material.dart';

class TodoPage extends StatefulWidget {
  final SearchState searchState;

  const TodoPage({
    super.key,
    required this.searchState,
  });

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TodoUpperSection(tabController: _tabController),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  TodoBuilder(
                    searchState: widget.searchState,
                    isDone: false,
                  ),
                  TodoBuilder(
                    searchState: widget.searchState,
                    isDone: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
