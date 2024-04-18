import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:to_do_list/constants/colors.dart';
import 'dart:math';

void main() async {
    // Register the adapter
    Hive.registerAdapter(TodoItemAdapter());

    // Initialize Hive
    await Hive.initFlutter();
    var box = await Hive.openBox('database');
    
    // Run the app
    runApp(const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(), // Apply theme as needed
    ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class TodoItem {
    String title;
    bool isCompleted;

    TodoItem(this.title, this.isCompleted);
}

class TodoItemAdapter extends TypeAdapter<TodoItem> {
  @override
  final int typeId = 0; // This ID should be unique and consistent across the app

  @override
  TodoItem read(BinaryReader reader) {
    final title = reader.readString();
    final isCompleted = reader.readBool();
    return TodoItem(title, isCompleted);
  }

  @override
  void write(BinaryWriter writer, TodoItem obj) {
    writer.writeString(obj.title);
    writer.writeBool(obj.isCompleted);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  // Define the todo list
  List<TodoItem> todoList = [];
  List<TodoItem> originalTodoList = [];
  // List of colors for initial note colors
  List<Color> initialNoteColors = [];
  
  // Open the Hive database
  final box = Hive.box('database');
  
  // Initialize the screen
  @override
  void initState() {
    super.initState();
    loadList();
    initialNoteColors = todoList.map((_) => getRandomColor()).toList().cast<Color>();
    
  }

  // Load the todo list from Hive
  void loadList() {
    originalTodoList = box.get('todolist', defaultValue: []).cast<TodoItem>();
    todoList = List.from(originalTodoList);
  }

  // Update the todo list in Hive
  void updateList() {
    box.put('todolist', todoList);
  }
  
  // Add an item to the list
  void addItem(String title) {
  TodoItem newItem = TodoItem(title, false);
  setState(() {
      todoList.add(newItem);
      originalTodoList.add(newItem);
      initialNoteColors.add(getRandomColor());
  });
  updateList();
  }

  // Delete an item from the list
  void deleteItem(int index) {
      setState(() {
          todoList.removeAt(index);
          originalTodoList.removeAt(index);
          initialNoteColors.removeAt(index);
      });
      updateList();
  }

  // Toggle completion status
  void toggleComplete(int index) {
    setState(() {
      todoList[index].isCompleted = !todoList[index].isCompleted;
    });
    updateList();
  }

  // Get a random color
  Color getRandomColor() {
    Random random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  // Search function for filtering notes
  void onSearchTextChanged(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        // If search text is empty, revert to the original list
        todoList = List.from(originalTodoList);
      } else {
        // Filter the todo list based on the original list
        todoList = originalTodoList
            .where((item) => item.title.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }
    });
  }
  
  // Show the form for adding a note
  void _showForm(BuildContext context) {
    final TextEditingController _listController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
            return AlertDialog(
                title: const Text("Add a Note"),
                content: SingleChildScrollView(
                    child: SizedBox(
                        width: 300.0,  // Maintain the desired width
                        child: Column(
                            children: [
                                const SizedBox(height: 20),
                                Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                        autofocus: true,
                                        controller: _listController,
                                        maxLines: 2,  // Allows the text field to expand vertically
                                        decoration: const InputDecoration(
                                            hintText: "Enter Content",
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
                actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                            Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                        ),
                        child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                            if (_listController.text.isNotEmpty) {
                                addItem(_listController.text);
                            }
                            Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                        ),
                        child: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                    ),
                ],
            );
        }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'To-Do List',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.blue,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                IconButton(
                  onPressed: () {
                  },
                  padding: const EdgeInsets.all(0),
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.event_note,
                      color: Colors.blue,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: onSearchTextChanged,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: "Search notes...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                fillColor: Colors.grey.shade200,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: todoList.isEmpty
                  ? Center(
                      child: Image.asset(
                        'assets/img/no-data.gif',
                        width: 400,
                        height: 400, // Customize the size as needed
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 30),
                      itemCount: todoList.length,
                      itemBuilder: (context, index) {
                        final item = todoList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 20),
                          color: item.isCompleted ? null : initialNoteColors[index],
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListTile(
                              leading: Checkbox(
                                value: item.isCompleted,
                                onChanged: (newValue) {
                                  toggleComplete(index);
                                },
                              ),
                              title: RichText(
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  text: item.title,
                                  style: TextStyle(
                                    color: item.isCompleted ? Colors.grey : Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    height: 1.5,
                                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  confirmDialog(context).then((result) {
                                    if (result != null && result) {
                                      deleteItem(index);
                                    }
                                  });
                                },
                                icon: const Icon(
                                  Icons.delete,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        elevation: 10,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(
          Icons.add,
          color: Colors.blue,
          size: 30,
        ),
      ),
    );
  }

  // Confirm dialog for deleting an item
  Future<bool?> confirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Task"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}