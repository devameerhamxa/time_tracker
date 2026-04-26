import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';
import '../models/app_models.dart';

class TimeEntryProvider extends ChangeNotifier {
  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<TimeEntry> _timeEntries = [];

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;
  List<TimeEntry> get timeEntries => _timeEntries;

  TimeEntryProvider() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    var storedProjects = localStorage.getItem('projects');
    if (storedProjects != null) {
      Iterable decoded = jsonDecode(storedProjects);
      _projects = List<Project>.from(
        decoded.map((item) => Project.fromJson(item)),
      );
    }

    var storedTasks = localStorage.getItem('tasks');
    if (storedTasks != null) {
      Iterable decoded = jsonDecode(storedTasks);
      _tasks = List<Task>.from(decoded.map((item) => Task.fromJson(item)));
    }

    var storedEntries = localStorage.getItem('timeEntries');
    if (storedEntries != null) {
      Iterable decoded = jsonDecode(storedEntries);
      _timeEntries = List<TimeEntry>.from(
        decoded.map((item) => TimeEntry.fromJson(item)),
      );
    }
    notifyListeners();
  }

  void _saveToStorage() {
    localStorage.setItem(
      'projects',
      jsonEncode(_projects.map((p) => p.toJson()).toList()),
    );
    localStorage.setItem(
      'tasks',
      jsonEncode(_tasks.map((t) => t.toJson()).toList()),
    );
    localStorage.setItem(
      'timeEntries',
      jsonEncode(_timeEntries.map((e) => e.toJson()).toList()),
    );
  }

  void addTimeEntry(TimeEntry entry) {
    _timeEntries.add(entry);
    _saveToStorage();
    notifyListeners();
  }

  void deleteTimeEntry(String id) {
    _timeEntries.removeWhere((entry) => entry.id == id);
    _saveToStorage();
    notifyListeners();
  }

  void addProject(Project project) {
    _projects.add(project);
    _saveToStorage();
    notifyListeners();
  }

  void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    _saveToStorage();
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveToStorage();
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    _saveToStorage();
    notifyListeners();
  }
}
