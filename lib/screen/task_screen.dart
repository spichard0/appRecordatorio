import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../task.dart'; // Asegúrate de ajustar la ruta según tu estructura de proyecto

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  TextEditingController _taskController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  List<Task> tasks = [];

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var androidSettings = AndroidInitializationSettings('app_icon');
    var iosSettings = IOSInitializationSettings();
    var macosSettings = MacOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macosSettings,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _scheduleNotification(String title, DateTime dateTime) async {
    var androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'channelDescription', // Descripción del canal aquí
      importance: Importance.high,
    );
    var iosDetails = IOSNotificationDetails();
    var platformDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Recordatorio de tarea',
      title,
      tz.TZDateTime.from(dateTime, tz.local),
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _addTask(String taskTitle, DateTime selectedDate, TimeOfDay selectedTime) {
    setState(() {
      tasks.add(
        Task(
          title: taskTitle.trim(),
          reminderDateTime: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
        ),
      );

      _scheduleNotification(taskTitle.trim(), selectedDate.add(Duration(hours: selectedTime.hour, minutes: selectedTime.minute)));

      _taskController.clear();
      _dateController.clear();
      _timeController.clear();
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
  }

  void _deleteSelectedTasks() {
    setState(() {
      tasks.removeWhere((task) => task.completed);
    });
  }

  void _toggleTaskCompleted(Task task) {
    setState(() {
      task.completed = !task.completed;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = "${picked.hour}:${picked.minute}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Ingrese una tarea',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      _addTask(_taskController.text, _selectedDate, _selectedTime);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Seleccione la fecha del recordatorio',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.date_range),
                        onPressed: () {
                          _selectDate(context);
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Seleccione la hora del recordatorio',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () {
                          _selectTime(context);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty && _dateController.text.isNotEmpty && _timeController.text.isNotEmpty) {
                  _addTask(_taskController.text, _selectedDate, _selectedTime);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Por favor, complete todos los campos para agregar la tarea con recordatorio.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Agregar Tarea con Recordatorio'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Checkbox(
                        value: tasks[index].completed,
                        onChanged: (checked) {
                          _toggleTaskCompleted(tasks[index]);
                        },
                      ),
                      title: Text(
                        tasks[index].title,
                        style: TextStyle(
                          fontSize: 18,
                          decoration: tasks[index].completed ? TextDecoration.lineThrough : null,
                          color: tasks[index].completed ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Fecha: ${tasks[index].reminderDateTime.day}/${tasks[index].reminderDateTime.month}/${tasks[index].reminderDateTime.year} '
                        'Hora: ${tasks[index].reminderDateTime.hour}:${tasks[index].reminderDateTime.minute}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteTask(tasks[index]);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _deleteSelectedTasks();
              },
              child: Text('Eliminar Tareas Seleccionadas'),
            ),
          ],
        ),
      ),
    );
  }
}
