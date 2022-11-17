import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_journal/screens/common/confirmation_dialog.dart';
import 'package:simple_journal/services/journal_service.dart';
import 'package:uuid/uuid.dart';

import '../../../helpers/weekday.dart';
import '../../../models/journal.dart';
import '../../common/exception_dialog.dart';

class JournalCard extends StatelessWidget {
  final Journal? journal;
  final DateTime showedDate;
  final VoidCallback refreshFunction;
  final int userId;
  final String token;
  const JournalCard({
    Key? key,
    this.journal,
    required this.showedDate,
    required this.refreshFunction,
    required this.userId,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (journal != null) {
      return InkWell(
        onTap: () {
          _callAddJournalScreen(context, journal: journal);
        },
        child: Container(
          height: 115,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black87,
            ),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    height: 75,
                    width: 75,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      border: Border(
                          right: BorderSide(color: Colors.black87),
                          bottom: BorderSide(color: Colors.black87)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      journal!.createdAt.day.toString(),
                      style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 38,
                    width: 75,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.black87),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(WeekDay(journal!.createdAt).short),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    journal!.content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    removeJournal(context);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.black54,
                  ))
            ],
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          _callAddJournalScreen(context);
        },
        child: Container(
          height: 115,
          alignment: Alignment.center,
          child: Text(
            "${WeekDay(showedDate).short} - ${showedDate.day}",
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  void _callAddJournalScreen(BuildContext context, {Journal? journal}) {
    Journal innerJournal = Journal(
        id: const Uuid().v1(),
        content: "",
        createdAt: showedDate,
        updatedAt: showedDate,
        userId: userId);

    Map<String, dynamic> argumentsMap = {};

    if (journal != null) {
      innerJournal = journal;
      argumentsMap.addEntries(const [MapEntry('is_editing', true)]);
    } else {
      argumentsMap.addEntries(const [MapEntry('is_editing', false)]);
    }

    argumentsMap.addEntries([MapEntry("journal", innerJournal)]);

    Navigator.pushNamed(
      context,
      'add-journal',
      arguments: argumentsMap,
    ).then((value) {
      if (value != null) {
        if (value == true) {
          refreshFunction();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registro feito com sucesso!")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Houve uma falha ao registrar!")));
        }
      }
    });
  }

  removeJournal(BuildContext context) {
    JournalService service = JournalService();
    if (journal != null) {
      showConfirmationDialog(context,
              content:
                  "Deseja realmente remover o diário do dia ${WeekDay(journal!.createdAt)}?",
              affirmativeOption: "remover")
          .then((value) {
        if (value != null) {
          if (value) {
            service.delete(id: journal!.id, token: token).then((value) {
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Removido com sucesso!"),
                  ),
                );
                refreshFunction();
              }
            }).catchError(
              (error) {
                logout();
              },
              test: (error) => error is InvalidTokenException,
            ).catchError((error) {
              showExceptionDialog(context,
                  content: (error as HttpException).message);
            }, test: ((error) => error is HttpException));
          }
        }
      });
    }
  }

  void logout() {}
}
