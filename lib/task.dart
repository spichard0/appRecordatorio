import 'package:flutter/material.dart';

class Task {
  late String title;
  late bool completed;
  late DateTime reminderDateTime; // Nueva propiedad para el recordatorio

  Task({
    required this.title,
    this.completed = false,
    required this.reminderDateTime, // Parámetro para el recordatorio
  });
}
