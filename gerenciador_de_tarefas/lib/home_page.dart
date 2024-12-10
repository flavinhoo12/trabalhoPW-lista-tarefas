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

  Future<void> _showTaskDialog({Map<String, dynamic>? task}) async {
    final titleController = TextEditingController(text: task?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: task?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task == null ? 'Adicionar Tarefa' : 'Editar Tarefa'),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTask = {
                'title': titleController.text,
                'description': descriptionController.text,
                'isCompleted': task?['isCompleted'] ?? 0,
              };

              if (task == null) {
                await DatabaseHelper.instance.insertTask(newTask);
              } else {
                newTask['id'] = task['id'];
                await DatabaseHelper.instance.updateTask(newTask);
              }
              Navigator.of(context).pop();
              _refreshTasks();
            },
            child: Text(task == null ? 'Adicionar' : 'Atualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _refreshTasks();
  }

  // String _getFormattedDate() {
  //   // Configura o locale para português
  //     Text("oi");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gerenciador de Tarefas'), actions: [Icon(Icons.person, size: 25,), SizedBox(width:  20,)], ),
      body: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  Text("oi"),
                  // Text(_getFormattedDate()),
                ],
              )
            ],
          ),
        ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(task['title']),
            subtitle: Text(task['description'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showTaskDialog(task: task),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTask(task['id']),
                ),
              ],
            ),
          );
        },
      ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}

      // body: 