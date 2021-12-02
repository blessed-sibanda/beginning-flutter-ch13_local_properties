import 'dart:math';

import 'package:ch13_local_properties/models/journal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditEntry extends StatefulWidget {
  final bool add;
  final int index;
  final JournalEdit journalEdit;

  const EditEntry({
    Key? key,
    required this.add,
    required this.index,
    required this.journalEdit,
  }) : super(key: key);

  @override
  _EditEntryState createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  late JournalEdit _journalEdit;
  late String _title;
  late DateTime _selectedDate;

  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final FocusNode _moodFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _journalEdit =
        JournalEdit(action: 'Cancel', journal: widget.journalEdit.journal);
    _title = widget.add ? 'Add' : 'Edit';
    if (widget.add) {
      _selectedDate = DateTime.now();
      _moodController.text = '';
      _noteController.text = '';
    } else {
      _selectedDate = _journalEdit.journal.date == null
          ? DateTime.parse(_journalEdit.journal.date!)
          : DateTime.now();
      _moodController.text = _journalEdit.journal.mood ?? '';
      _noteController.text = _journalEdit.journal.note ?? '';
    }
  }

  @override
  void dispose() {
    _moodController.dispose();
    _noteController.dispose();
    _moodFocus.dispose();
    _noteFocus.dispose();

    super.dispose();
  }

  // DatePicker
  Future<DateTime> _selectDate(
      BuildContext context, DateTime selectedDate) async {
    DateTime _initialDate = selectedDate;
    DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (_pickedDate != null) {
      selectedDate = DateTime(
        _pickedDate.year,
        _pickedDate.month,
        _pickedDate.day,
        _pickedDate.hour,
        _pickedDate.minute,
        _pickedDate.second,
        _pickedDate.millisecond,
        _pickedDate.microsecond,
      );
    }
    return selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_title Entry'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextButton(
                  onPressed: () async {
                    // Dismiss the keyboard if any of the TextFields have focus
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime _pickedDate =
                        await _selectDate(context, _selectedDate);
                    setState(() => _selectedDate = _pickedDate);
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 22.0,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 16.0),
                      Text(
                        DateFormat.yMMMEd().format(_selectedDate),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_back,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: _moodController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  focusNode: _moodFocus,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Mood',
                    icon: Icon(Icons.mood),
                  ),
                  onSubmitted: (submitted) {
                    FocusScope.of(context).requestFocus(_noteFocus);
                  },
                ),
                TextField(
                  controller: _noteController,
                  autofocus: true,
                  textInputAction: TextInputAction.newline,
                  focusNode: _noteFocus,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    icon: Icon(Icons.subject),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _journalEdit.action = 'Cancel';
                        Navigator.pop(context, _journalEdit);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey.shade100),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    TextButton(
                      onPressed: () {
                        _journalEdit.action = 'Save';
                        String _id = widget.add
                            ? Random().nextInt(999999).toString()
                            : _journalEdit.journal.id!;

                        _journalEdit.journal = Journal(
                          id: _id,
                          date: _selectedDate.toString(),
                          mood: _moodController.text,
                          note: _noteController.text,
                        );
                        Navigator.pop(context, _journalEdit);
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.lightGreen.shade100),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
