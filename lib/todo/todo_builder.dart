import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoBuilder extends StatefulWidget {
  const TodoBuilder({super.key});

  @override
  State<TodoBuilder> createState() => _TodoBuilderState();
}

class _TodoBuilderState extends State<TodoBuilder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('todos')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final todos = snapshot.data!.docs;

        if (todos.isEmpty) {
          return const Center(
            child: Text(
              'No tasks available. Add some tasks!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            final data = todo.data();

            final title = data.containsKey('title') ? data['title'] : null;
            final description =
                data.containsKey('description') ? data['description'] : '';
            final time = data.containsKey('time') ? data['time'] : null;
            final date = data.containsKey('date') ? data['date'] : null;

            return Dismissible(
              key: Key(todo.id),
              direction: DismissDirection.horizontal,
              background: Container(
                color: Colors.blue,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20.0),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  // Show update form
                  return await _showUpdateDialog(context, todo.id, data);
                } else if (direction == DismissDirection.endToStart) {
                  // Show delete confirmation
                  bool? shouldDelete = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          'Delete Task',
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to delete this task?',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                    color: Colors.black,
                                    width: 1.0), // Add black border
                              ),
                              backgroundColor: Colors
                                  .black, // Optional: To make the button background visible
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                    color: Colors.black,
                                    width: 1.0), // Add black border
                              ),
                              backgroundColor: Colors
                                  .black, // Optional: To make the button background visible
                            ),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('todos')
                                  .doc(todo.id)
                                  .delete();
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              'Yes',
                              style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  return shouldDelete ?? false;
                }
                return false;
              },
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      activeColor: Colors.blue,
                      value: data['isDone'] ?? false,
                      onChanged: (value) {
                        FirebaseFirestore.instance
                            .collection('todos')
                            .doc(todo.id)
                            .update({'isDone': value});
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null && title.isNotEmpty)
                            Text(
                              title,
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text(
                            description,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (time != null && time.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.alarm, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  '$time',
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          if (date != null && date.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.calendar_month,
                                    color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  '$date',
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _showUpdateDialog(
      BuildContext context, String docId, Map<String, dynamic> data) async {
    final TextEditingController titleController =
        TextEditingController(text: data['title']);
    final TextEditingController descriptionController =
        TextEditingController(text: data['description']);
    final TextEditingController dateController =
        TextEditingController(text: data['date']);
    final TextEditingController timeController =
        TextEditingController(text: data['time']);

    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Update Task',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: 'Time'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                      color: Colors.black, width: 1.0), // Add black border
                ),
                backgroundColor: Colors
                    .black, // Optional: To make the button background visible
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                      color: Colors.black, width: 1.0), // Add black border
                ),
                backgroundColor: Colors
                    .black, // Optional: To make the button background visible
              ),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('todos')
                    .doc(docId)
                    .update({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'date': dateController.text,
                  'time': timeController.text,
                }).then((_) {
                  Navigator.of(context).pop(true);
                  setState(() {}); // Trigger immediate UI update
                }).catchError((error) {
                  Navigator.of(context).pop(false);
                });
              },
              child: Text(
                'Update',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
