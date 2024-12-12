import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<Todo> _todos = [];
  final TextEditingController _todoController = TextEditingController();
  DateTime? _selectedDate;

  void _addTodo() {
    if (_todoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task cannot be empty!')),
      );
      return;
    }

    setState(() {
      _todos.add(Todo(
        task: _todoController.text,
        dateTime: _selectedDate ?? DateTime.now(),
        id: DateTime.now().millisecondsSinceEpoch,
      ));
      _todoController.clear();
      _selectedDate = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todo added successfully!')),
    );
  }

  void _deleteTodo(int id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todo deleted successfully!')),
    );
  }

  void _editTodoModal(Todo todo) {
    _todoController.text = todo.task;
    _selectedDate = todo.dateTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Todo',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      labelText: 'Todo Task',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'No date selected'
                              : DateFormat('MMM dd, yyyy')
                                  .format(_selectedDate!),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setModalState(() {
                              _selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        final index = _todos.indexWhere((t) => t.id == todo.id);
                        if (index != -1) {
                          _todos[index] = Todo(
                            id: todo.id,
                            task: _todoController.text,
                            dateTime: _selectedDate,
                          );
                        }
                      });

                      _todoController.clear();
                      _selectedDate = null;
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Todo edited successfully!')),
                      );
                    },
                    child: const Text('Save'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Todo Input Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      hintText: 'Enter a new task',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Colors.blue,
                  onPressed: _addTodo,
                ),
              ],
            ),

            // Selected Date Display
            if (_selectedDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Selected Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

            // Todo List
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        todo.task,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: todo.dateTime != null
                          ? Text(
                              DateFormat('MMM dd, yyyy').format(todo.dateTime!),
                              style: const TextStyle(color: Colors.grey),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editTodoModal(todo),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTodo(todo.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Todo {
  final int id;
  final String task;
  final DateTime? dateTime;

  Todo({
    required this.id,
    required this.task,
    this.dateTime,
  });
}
