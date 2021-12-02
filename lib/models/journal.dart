class Journal {
  String? id;
  String? date;
  String? mood;
  String? note;

  Journal({
    this.id,
    this.date,
    this.mood,
    this.note,
  });

  factory Journal.fromJson(Map<String, dynamic> json) => Journal(
        id: json['id'],
        date: json['date'],
        mood: json['mood'],
        note: json['note'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'mood': mood,
        'note': note,
      };
}

// The JournalEdit class is responsible for passing the `action` and `journal` entry between pages
class JournalEdit {
  String action;
  Journal journal;

  JournalEdit({
    required this.action,
    required this.journal,
  });
}
