class Note {
  int id;
  String content;
  bool isChecked;

  Note({
    required this.id,
    required this.content,
    this.isChecked = false,
  });
}


List<Note> sampleNotes = [
  Note(
    id: 0,
    content:
        'A FREE way to support the channel is to give us a LIKE . It does not cost you but means a lot to us.\nIf you are new here please Subscribe',
  ),
  Note(
    id: 1,
    content:
        '1. Chicken Alfredo\n2. Vegan chili\n3. Spaghetti carbonara\n4. Chocolate lava cake',
  ),
  Note(
    id: 2,
    content:
        '1. To Kill a Mockingbird\n2. 1984\n3. The Great Gatsby\n4. The Catcher in the Rye',
  ),
  Note(
    id: 3,
    content: '1. Jewelry box\n2. Cookbook\n3. Scarf\n4. Spa day gift card',
  ),
  Note(
    id: 4,
    content:
        'Monday:\n- Run 5 miles\n- Yoga class\nTuesday:\n- HIIT circuit training\n- Swimming laps\nWednesday:\n- Rest day\nThursday:\n- Weightlifting\n- Spin class\nFriday:\n- Run 3 miles\n- Pilates class\nSaturday:\n- Hiking\n- Rock climbing',
  ),
];
