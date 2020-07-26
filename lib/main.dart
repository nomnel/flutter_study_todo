import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoData(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'todo app'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<TodoData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: data.length(),
        itemBuilder: (context, index) {
          var todo = data.get(index);
          return ListTile(
            leading: GestureDetector(
              child: todo.isDone
                  ? Icon(Icons.check_box)
                  : Icon(Icons.check_box_outline_blank),
              onTap: () {
                data.toggleStatus(index);
              },
            ),
            title: data.isActive(index)
                ? TextField(
                    controller: TextEditingController(text: todo.body),
                    onEditingComplete: data.inactivate,
                    onSubmitted: (value) {
                      data.update(index, value);
                    },
                  )
                : GestureDetector(
                    child: Text(todo.body),
                    onTap: () {
                      data.activate(index);
                    },
                  ),
            trailing: GestureDetector(
              child: Icon(Icons.delete),
              onTap: () {
                data.remove(index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: data.add,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class TodoData extends ChangeNotifier {
  int _activeIndex = -1;
  List<Todo> _todoList = [];

  void activate(int index) {
    _activeIndex = index;
    notifyListeners();
  }

  void add() {
    _todoList.insert(0, Todo(''));
    activate(0);
  }

  List<Todo> all() => _todoList;

  Todo get(int index) => _todoList[index];

  void inactivate() {
    _activeIndex = -1;
    notifyListeners();
  }

  bool isActive(int index) => index == _activeIndex;

  int length() => _todoList.length;

  void remove(int index) {
    _todoList.removeAt(index);
    inactivate();
  }

  void toggleStatus(int index) {
    var todo = _todoList[index];
    todo.isDone = !todo.isDone;
    inactivate();
  }

  void update(int index, String body) {
    _todoList[index].body = body;
    inactivate();
  }
}

class Todo {
  String body;
  bool isDone;
  DateTime createdAt;

  Todo(this.body) {
    this.isDone = false;
    this.createdAt = DateTime.now();
  }
}
