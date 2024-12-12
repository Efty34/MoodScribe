import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DiaryEntry extends StatefulWidget {
  const DiaryEntry({super.key});

  @override
  _DiaryEntryState createState() => _DiaryEntryState();
}

class _DiaryEntryState extends State<DiaryEntry> {
  final TextEditingController _postController = TextEditingController();
  late Box<String> diaryBox;

  @override
  void initState() {
    super.initState();
    // Open the Hive box
    diaryBox = Hive.box<String>('diaryBox');
  }

  void _saveEntry() {
    final text = _postController.text.trim();
    if (text.isNotEmpty) {
      diaryBox.add(text); // Save the text into the Hive box
      _postController.clear(); // Clear the TextField
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your diary entry has been saved!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before saving.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inspirational Text
              Text(
                'Ease Your Mind, \nLighten Your Heart.',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Every moment tells a story. What\'s yours today?',
                style: GoogleFonts.dancingScript(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),

              // Textarea-like TextField
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextField(
                    controller: _postController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Chronicles of a Wandering Mind...',
                      hintStyle: GoogleFonts.manrope(
                        color: Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              Center(
                child: OutlinedButton.icon(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  onPressed: _saveEntry,
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                    color: Colors.black,
                  ),
                  label: Text(
                    "Save the Day",
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}
