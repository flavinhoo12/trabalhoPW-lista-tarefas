import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'DBHelper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future<void> _refreshTasks() async {
    final data = await DatabaseHelper.instance.getTasks();
    setState(() {
      _tasks = data;
    });
  }

  Future<void> _addTask() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDateTime;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nova Tarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDateTime = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDateTime != null) {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedDateTime = DateTime(
                        pickedDateTime.year,
                        pickedDateTime.month,
                        pickedDateTime.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: Text('Selecionar Data e Hora'),
            ),
            if (selectedDateTime != null)
              Text(
                'Data e Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime!)}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && selectedDateTime != null) {
                final newTask = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'datetime': selectedDateTime!.toIso8601String(),
                };
                await DatabaseHelper.instance.insertTask(newTask);
                _refreshTasks();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tarefa adicionada com sucesso!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Por favor, preencha todos os campos')),
                );
              }
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _editTask(Map<String, dynamic> task) async {
    final TextEditingController titleController = TextEditingController(text: task['title']);
    final TextEditingController descriptionController = TextEditingController(text: task['description']);
    DateTime? selectedDateTime = DateTime.parse(task['datetime']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Tarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDateTime = await showDatePicker(
                  context: context,
                  initialDate: selectedDateTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDateTime != null) {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDateTime!),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedDateTime = DateTime(
                        pickedDateTime.year,
                        pickedDateTime.month,
                        pickedDateTime.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: Text('Selecionar Data e Hora'),
            ),
            if (selectedDateTime != null)
              Text(
                'Data e Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime!)}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && selectedDateTime != null) {
                final updatedTask = {
                  'id': task['id'],
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'datetime': selectedDateTime!.toIso8601String(),
                };
                await DatabaseHelper.instance.updateTask(updatedTask);
                _refreshTasks();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tarefa atualizada com sucesso!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Por favor, preencha todos os campos')),
                );
              }
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _refreshTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarefa removida com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciador de Tarefas'),
      ),
      body: _tasks.isEmpty
          ? Center(child: Text('Nenhuma tarefa cadastrada'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(task['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Descrição: ${task['description'] ?? "Sem descrição"}'),
                        Text(
                          'Data e Hora: ${task['datetime'] != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(task['datetime'])) : "Data não disponível"}',
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(task['id']),
                    ),
                    onTap: () => _editTask(task), // To edit the task on tap
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
        tooltip: 'Adicionar Tarefa',
      ),
    );
  }
}
