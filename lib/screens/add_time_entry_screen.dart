import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../models/app_models.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  // State variables for form fields [cite: 30]
  Project? selectedProject;
  Task? selectedTask;
  DateTime selectedDate = DateTime.now();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Function to handle Date Selection [cite: 30]
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimeEntryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Time Entry'),
        backgroundColor: const Color(
          0xFF4D9084,
        ), // Matching image theme [cite: 48]
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Selection [cite: 30]
            const Text(
              'Project',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<Project>(
              isExpanded: true,
              hint: const Text('Select Project'),
              value: selectedProject,
              items: provider.projects
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                  .toList(),
              onChanged: (val) => setState(() => selectedProject = val),
            ),
            const SizedBox(height: 20),

            // Task Selection [cite: 30]
            const Text('Task', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<Task>(
              isExpanded: true,
              hint: const Text('Select Task'),
              value: selectedTask,
              items: provider.tasks
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (val) => setState(() => selectedTask = val),
            ),
            const SizedBox(height: 20),

            // Date Picker [cite: 30, 48]
            Text(
              'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
              style: const TextStyle(fontSize: 16),
            ),
            OutlinedButton(
              onPressed: () => _selectDate(context),
              child: const Text('Select Date'),
            ),
            const SizedBox(height: 20),

            // Total Time Input [cite: 30]
            const Text(
              'Total Time (in hours)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: timeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '1'),
            ),
            const SizedBox(height: 20),

            // Note Input [cite: 30]
            const Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(hintText: 'new work'),
            ),
            const SizedBox(height: 30),

            // Save Button [cite: 8, 31]
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  if (selectedProject != null &&
                      selectedTask != null &&
                      timeController.text.isNotEmpty) {
                    final newEntry = TimeEntry(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      projectId: selectedProject!.id,
                      taskId: selectedTask!.id,
                      totalTime: double.tryParse(timeController.text) ?? 0.0,
                      date: selectedDate,
                      note: noteController.text,
                    );

                    // Save to local storage via Provider [cite: 8, 31, 44]
                    provider.addTimeEntry(newEntry);
                    Navigator.pop(context); // Return to Home [cite: 47]
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                      ),
                    );
                  }
                },
                child: const Text('Save Time Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
