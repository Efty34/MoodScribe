import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TodoBuilder extends StatelessWidget {
  const TodoBuilder({super.key});

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

            // Check if fields exist before accessing them
            final title = data.containsKey('title') ? data['title'] : null;
            final description =
                data.containsKey('description') ? data['description'] : '';
            final time = data.containsKey('time') ? data['time'] : null;
            final date = data.containsKey('date') ? data['date'] : null;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // color: Colors.blue[50],
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (time != null && time.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.alarm, color: Colors.red[400]),
                              const SizedBox(width: 4),
                              Text(
                                '$time',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.red[400],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        if (date != null && date.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.calendar_month,
                                  color: Colors.red[400]),
                              const SizedBox(width: 4),
                              Text(
                                '$date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red[400],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [

                  //   ],
                  // )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
