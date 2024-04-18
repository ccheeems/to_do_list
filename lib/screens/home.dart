import 'dart:math';

import 'package:flutter/material.dart';
import 'package:to_do_list/constants/colors.dart';
import 'package:to_do_list/models/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> filteredNotes = [];
  List<Color> initialNoteColors = []; // List to hold initial colors of notes

  @override
  void initState() {
    super.initState();
    filteredNotes = sampleNotes;

    initialNoteColors = sampleNotes.map((_) => getRandomColor()).toList().cast<Color>();
  }

  getRandomColor() {
    Random random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = sampleNotes
          .where((note) =>
              note.content.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void deleteNote(int index) {
    setState(() {
      Note note = filteredNotes[index];
      sampleNotes.remove(note);
      filteredNotes.removeAt(index);
    });
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
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(
                        Icons.event_note,
                        color: Colors.blue,
                      ),
                    ))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
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
              child: filteredNotes.isEmpty
                  ? Center(
                      child: Image.asset(
                        'assets/img/no-data.gif',
                        width: 200,
                        height: 200, // Customize the size as needed
                      ),
                    )
                  : ListView.builder(
                
              padding: const EdgeInsets.only(top: 30),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
              return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: filteredNotes[index].isChecked
                      ? null // Set color to null if the note is checked
                      : initialNoteColors[index], // Use initial color if the note is unchecked
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                          leading: Checkbox(
                              value: filteredNotes[index].isChecked,
                              onChanged: (newValue) {
                                  setState(() {
                                      filteredNotes[index].isChecked = newValue!;
                                  });
                              },
                          ),
                          title: RichText(
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  text: filteredNotes[index].content,
                                  style: TextStyle(
                                      color: filteredNotes[index].isChecked
                                          ? Colors.grey // Use grey color when checked
                                          : Colors.black, // Use black color when unchecked
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      height: 1.5,
                                      decoration: filteredNotes[index].isChecked
                                          ? TextDecoration.lineThrough // Underline if checked
                                          : null, // No decoration when unchecked
                                  ),
                              ),
                          ),
                          trailing: IconButton(
                              onPressed: () async {
                                  final result = await confirmDialog(context);
                                  if (result != null && result) {
                                      deleteNote(index);
                                  }
                              },
                              icon: const Icon(
                                  Icons.delete,
                              ),
                          ),
                      ),
                  ),
              );
              },
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          return _showForm(context);
        },
        elevation: 10,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(
          Icons.add,
          size: 38,
        ),
      ),
    );
  }

  Future<dynamic> confirmDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            icon: const Icon(
              Icons.info,
              color: Colors.black,
            ),
            title: const Text(
              'Are you sure you want to delete?',
              style: TextStyle(color: Colors.black),
            ),
            content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const SizedBox(
                        width: 60,
                        child: Text(
                          'Yes',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const SizedBox(
                        width: 60,
                        child: Text(
                          'No',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ]),
          );
        });
  }

  void _showForm(BuildContext context) {
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
                          // Update filteredNotes to include the new note
                          //filteredNotes = sampleNotes.toList();
                          // Also add a new random color for the new note
                          //initialNoteColors.add(getRandomColor());
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

}
