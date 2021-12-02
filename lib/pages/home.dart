import 'package:ch13_local_properties/models/journal.dart';
import 'package:ch13_local_properties/pages/edit_entry.dart';
import 'package:ch13_local_properties/utils/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Database _database;

  void _addOrEditJournal(
    context, {
    required bool add,
    required int index,
    required Journal journal,
  }) async {
    JournalEdit _journalEdit = JournalEdit(action: '', journal: journal);
    _journalEdit = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEntry(
          add: add,
          index: index,
          journalEdit: _journalEdit,
        ),
        fullscreenDialog: true,
      ),
    );
    print('journalEdit -> ${_journalEdit.action}');
    switch (_journalEdit.action) {
      case 'Save':
        if (add) {
          setState(() {
            _database.journals.add(_journalEdit.journal);
            print(_database.journals.first.toJson());
          });
        } else {
          _database.journals[index] = _journalEdit.journal;
        }
        DatabaseFileRoutines().writeJournals(databaseToJson(_database));
        break;
      case 'Cancel':
        break;
      default:
        break;
    }
  }

  Future<List<Journal>> _loadJournals() async {
    String journalsJson = await DatabaseFileRoutines().readJournals();
    _database = databaseFromJson(journalsJson);
    _database.journals.sort((j1, j2) => j2.date.compareTo(j1.date));
    return _database.journals;
  }

  @override
  void initState() {
    super.initState();
    _database = Database(journals: []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        initialData: const [],
        future: _loadJournals(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return !snapshot.hasData
              ? const Center(child: CircularProgressIndicator())
              : _buildListViewSeparated(snapshot);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditJournal(context,
            add: true, index: -1, journal: Journal.empty()),
        tooltip: 'Add Journal Entry',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(padding: EdgeInsets.all(24.0)),
        color: Colors.blue,
      ),
    );
  }

  Widget _buildListViewSeparated(AsyncSnapshot snapshot) {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        String _titleDate = DateFormat.yMMMd()
            .format(DateTime.parse(snapshot.data[index].date));
        String _subtitle =
            snapshot.data[index].mood + '\n' + snapshot.data[index].note;
        return Dismissible(
          key: Key(snapshot.data[index].id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (direction) {
            setState(() {
              _database.journals.removeAt(index);
            });
            DatabaseFileRoutines().writeJournals(databaseToJson(_database));
          },
          child: ListTile(
            leading: Column(
              children: [
                Text(
                  DateFormat.d().format(
                    DateTime.parse(snapshot.data[index].date),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32.0,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  DateFormat.E().format(snapshot.data[index].date),
                ),
              ],
            ),
            title: Text(
              _titleDate,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_subtitle),
            onTap: () {
              _addOrEditJournal(context,
                  add: false, index: index, journal: snapshot.data[index]);
            },
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
        color: Colors.grey,
      ),
      itemCount: snapshot.data.length,
    );
  }
}
