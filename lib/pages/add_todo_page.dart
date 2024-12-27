import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  _AddTodoPageState createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _saveTodo() {
    if (_titleController.text.isNotEmpty &&
        _selectedTime != null &&
        _selectedDate != null) {
      FirebaseFirestore.instance.collection('todos').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'time': _selectedTime!.format(context),
        'date': DateFormat.yMMMd().format(_selectedDate!),
        'isDone': false,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Task',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime == null
                      ? 'Select Time'
                      : _selectedTime!.format(context),
                ),
                ElevatedButton(
                  onPressed: _selectTime,
                  child: Text('Pick Time'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : DateFormat.yMMMd().format(_selectedDate!),
                ),
                ElevatedButton(
                  onPressed: _selectDate,
                  child: Text('Pick Date'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _saveTodo,
                child: Text('Save Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
