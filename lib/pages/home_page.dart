import 'package:diary/components/custom_app_bar.dart';
import 'package:diary/components/custom_app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Open the Hive box
    final Box<String> diaryBox = Hive.box<String>('diaryBox');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      drawer: const CustomAppDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ValueListenableBuilder(
          valueListenable: diaryBox.listenable(),
          builder: (context, Box<String> box, _) {
            // Check if the box is empty
            if (box.isEmpty) {
              return const Center(
                child: Text(
                  'No diary entries yet. Add some thoughts!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            // Build the MasonryGridView with diary entries
            return MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: box.length,
              itemBuilder: (context, index) {
                final String entry = box.getAt(index) ?? '';

                return GestureDetector(
                  onLongPress: () => _showOptions(context, box, index, entry),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // color: Colors.brown.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.withOpacity(0.5),
                      //     spreadRadius: 2,
                      //     blurRadius: 5,
                      //     offset: const Offset(0, 3),
                      //   ),
                      // ],
                    ),
                    child: Text(
                      entry,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showOptions(
      BuildContext context, Box<String> box, int index, String entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, box, index, entry);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, box, index);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(
      BuildContext context, Box<String> box, int index, String entry) {
    final TextEditingController controller = TextEditingController(text: entry);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Entry'),
          content: TextField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(hintText: 'Update your note'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedText = controller.text.trim();
                if (updatedText.isNotEmpty) {
                  box.putAt(index, updatedText);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note updated successfully!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Box<String> box, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                box.deleteAt(index);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note deleted successfully!')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
