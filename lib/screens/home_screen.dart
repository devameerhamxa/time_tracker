import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_app/models/app_models.dart';
import 'package:time_tracker_app/providers/time_entry_provider.dart';
import 'package:time_tracker_app/screens/task_management_screen.dart';
import 'add_time_entry_screen.dart';
import 'project_management_screen.dart';
import 'package:collection/collection.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: const Text(
              'Time Tracking',
              style: TextStyle(color: Colors.white),
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            tabs: [
              Tab(text: 'All Entries'),
              Tab(text: 'Grouped by Projects'),
            ],
          ),
          backgroundColor: const Color(0xFF4D9084),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.teal),
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Projects'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProjectManagementScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Tasks'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TaskManagementScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_AllEntriesView(), _GroupedEntriesView()],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amber,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTimeEntryScreen()),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _AllEntriesView extends StatelessWidget {
  const _AllEntriesView();

  @override
  Widget build(BuildContext context) {
    // Access the provider to get the list of entries
    final provider = context.watch<TimeEntryProvider>();
    final entries = provider.timeEntries;

    if (entries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No time entries yet!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text('Tap the + button to add your first entry.'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        // Find the project name based on the ID saved in the entry
        final projectName = provider.projects
            .firstWhere(
              (p) => p.id == entry.projectId,
              orElse: () => Project(id: '', name: 'Unknown Project'),
            )
            .name;

        return ListTile(
          title: Text(projectName),
          subtitle: Text('${entry.totalTime} hours - ${entry.note}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => provider.deleteTimeEntry(entry.id),
          ),
        );
      },
    );
  }
}

class _GroupedEntriesView extends StatelessWidget {
  const _GroupedEntriesView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimeEntryProvider>();

    // Using the collection package to group entries by project ID
    final grouped = groupBy(provider.timeEntries, (TimeEntry e) => e.projectId);

    if (grouped.isEmpty) {
      return const Center(child: Text('No data to group yet.'));
    }

    return ListView(
      children: grouped.entries.map((group) {
        final projectId = group.key;
        final entries = group.value;

        final projectName = provider.projects
            .firstWhere(
              (p) => p.id == projectId,
              orElse: () => Project(id: '', name: 'Unknown Project'),
            )
            .name;

        // Calculate total hours for this project
        final totalHours = entries.fold<double>(
          0,
          (sum, item) => sum + item.totalTime,
        );

        return ExpansionTile(
          title: Text(projectName),
          trailing: Text(
            '$totalHours hrs',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: entries
              .map(
                (e) => ListTile(
                  title: Text('Task Time: ${e.totalTime} hrs'),
                  subtitle: Text(e.note),
                ),
              )
              .toList(),
        );
      }).toList(),
    );
  }
}
