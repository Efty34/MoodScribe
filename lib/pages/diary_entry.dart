import 'dart:convert';

import 'package:diary/firebase/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class DiaryEntry extends StatefulWidget {
  const DiaryEntry({super.key});

  @override
  // ignore: library_private_types_in_public_api
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

  void _saveEntry() async {
    final text = _postController.text.trim();
    if (text.isNotEmpty) {
      try {
        diaryBox.add(text); // Save the text into the Hive box

        // Fetch prediction from backend
        final prediction =
            await monitorStress(text); // Ensure this returns a String

        // Save to Firebase using FirebaseOptions
        await FirebaseOptions.saveDiaryEntry(text, prediction);

        // Clear the TextField
        _postController.clear();

        // Notify user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your diary entry has been saved!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before saving.')),
      );
    }
  }

  Future<String> monitorStress(String text) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8000/predict');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'text': text}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['prediction'] as String; // Return the prediction
      } else {
        return 'Error: Unable to fetch prediction.';
      }
    } catch (e) {
      return 'Error: $e';
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
