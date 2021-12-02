import 'package:ch13_local_properties/models/journal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class DatabaseFileRoutines {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_persistence.json');
  }

  Future<String> readJournals() async {
    try {
      final file = await _localFile;
      if (!file.existsSync()) {
        print('File does not Exist: ${file.absolute}');
        await writeJournals('{"journals": []}');
      }
      // Read the file
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      print('error readJournals: $e');
      return '';
    }
  }

  Future<File> writeJournals(String json) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(json);
  }
}

// To read and parse JSON data
Database databaseFromJson(String str) {
  final dataFromJson = json.decode(str);
  return Database.fromJson(dataFromJson);
}

// To save and parse to JSON data
String databaseToJson(Database data) {
  final dataToJson = data.toJson();
  return json.encode(dataToJson);
}

class Database {
  List<Journal> journals;

  Database({required this.journals});

  factory Database.fromJson(Map<String, dynamic> json) => Database(
        journals: List<Journal>.from(
            json['journals'].map((x) => Journal.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'journals': List<dynamic>.from(journals.map((x) => x.toJson())),
      };
}
