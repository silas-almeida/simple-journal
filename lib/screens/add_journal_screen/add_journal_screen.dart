import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_journal/models/journal.dart';
import 'package:simple_journal/services/journal_service.dart';

import '../../helpers/logout.dart';
import '../../helpers/weekday.dart';
import '../common/exception_dialog.dart';

class AddJournalScreen extends StatelessWidget {
  final Journal journal;
  final bool isEditing;
  final TextEditingController _contentController = TextEditingController();

  AddJournalScreen({Key? key, required this.journal, this.isEditing = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _contentController.text = journal.content;
    return Scaffold(
      appBar: AppBar(
        title: Text(WeekDay(journal.createdAt).toString()),
        actions: [
          IconButton(
              onPressed: () {
                _registerJournal(context);
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _contentController,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 24),
          expands: true,
          minLines: null,
          maxLines: null,
        ),
      ),
    );
  }

  Future<void> _registerJournal(BuildContext context) async {
    SharedPreferences.getInstance().then(
      (prefs) {
        String? token = prefs.getString("accessToken");
        if (token != null) {
          String content = _contentController.text;
          journal.content = content;
          JournalService service = JournalService();
          if (isEditing) {
            service
                .edit(id: journal.id, journal: journal, token: token)
                .then((value) {
              Navigator.pop(context, value);
            }).catchError(
              (error) {
                logout(context);
              },
              test: (error) => error is InvalidTokenException,
            ).catchError(
              (error) {
                showExceptionDialog(context,
                    content: (error as HttpException).message);
              },
              test: ((error) => error is HttpException),
            );
          } else {
            service
                .register(journal: journal, token: token)
                .then(
                  (value) => Navigator.pop(context, value),
                )
                .catchError(
              (error) {
                logout(context);
              },
              test: (error) => error is InvalidTokenException,
            ).catchError(
              (error) {
                showExceptionDialog(context,
                    content: (error as HttpException).message);
              },
              test: ((error) => error is HttpException),
            );
          }
        }
      },
    );
  }
}
