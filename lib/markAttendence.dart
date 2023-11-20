import 'package:flutter/material.dart';

class attendence extends StatefulWidget {
  @override
  _ToDoListAppState createState() => _ToDoListAppState();
}

class _ToDoListAppState extends State<attendence> {
  List<TodoItem> _todoItems = [];

  void _addTodoItem(String task) {
    setState(() {
      _todoItems.add(TodoItem(task: task, completed: false));
    });
  }

  // void _removeTodoItem(int index) {
  //   setState(() {
  //     _todoItems.removeAt(index);
  //   });
  // }

  void _toggleTodoItem(int index) {
    setState(() {
      _todoItems[index].completed = !_todoItems[index].completed;
    });
  }

  int _getCompletedTasksCount() {
    int count = 0;
    for (var item in _todoItems) {
      if (item.completed) {
        count++;
      }
    }
    return count;
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todoItems.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: Checkbox(
            value: _todoItems[index].completed,
            onChanged: (value) {
              _toggleTodoItem(index);
            },
          ),
          title: Text(
            _todoItems[index].task,
            style: TextStyle(
              decoration: _todoItems[index].completed
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          // trailing: IconButton(
          //   icon: Icon(Icons.delete),
          //   onPressed: () {
          //     _removeTodoItem(index);
          //   },
          // ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int completedTasksCount = _getCompletedTasksCount();

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendence Section'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Present Student: $completedTasksCount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Expanded(
            child: _buildTodoList(),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'add student',
              ),
              onSubmitted: (text) {
                _addTodoItem(text);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TodoItem {
  String task;
  bool completed;

  TodoItem({
    required this.task,
    required this.completed,
  });
}

void main() {
  runApp(attendence());
}
