import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

part 'main.g.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>(TodoData.boxName);
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
        itemBuilder: _listItemBuilder,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: data.add,
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _listItemBuilder(BuildContext context, int index) {
    var data = Provider.of<TodoData>(context);
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
  }
}

class TodoData extends ChangeNotifier {
  static const String boxName = 'todos';

  int _activeIndex = -1;
  Box<Todo> _box;
  List<Todo> _todoList;

  TodoData() {
    _box = Hive.box<Todo>(boxName);
    _todoList = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void activate(int index) {
    _activeIndex = index;
    notifyListeners();
  }

  void add() {
    var todo = Todo('');
    _box.put(todo.id, todo);
    _todoList.insert(0, todo);
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
    var todo = _todoList[index];
    _box.delete(todo.id);
    _todoList.removeAt(index);
    inactivate();
  }

  void toggleStatus(int index) {
    var todo = _todoList[index];
    todo.isDone = !todo.isDone;
    _box.put(todo.id, todo);
    inactivate();
  }

  void update(int index, String body) {
    var todo = _todoList[index];
    todo.body = body;
    _box.put(todo.id, todo);
    inactivate();
  }
}

@HiveType(typeId: 1)
class Todo {
  @HiveField(0)
  String id;
  @HiveField(1)
  String body;
  @HiveField(2)
  bool isDone;
  @HiveField(3)
  DateTime createdAt;

  Todo(this.body) {
    var now = DateTime.now();
    this.id = now.millisecondsSinceEpoch.toString();
    this.isDone = false;
    this.createdAt = now;
  }
}
