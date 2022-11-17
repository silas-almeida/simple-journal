import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_journal/screens/common/exception_dialog.dart';
import 'package:simple_journal/screens/home_screen/widgets/home_screen_list.dart';
import 'package:simple_journal/services/auth_service.dart';
import 'package:simple_journal/services/journal_service.dart';
import '../../helpers/logout.dart';
import '../../models/journal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // O último dia apresentado na lista
  DateTime currentDay = DateTime.now();

  // Tamanho da lista
  int windowPage = 10;

  // A base de dados mostrada na lista
  Map<String, Journal> database = {};

  final ScrollController _listScrollController = ScrollController();

  JournalService journalService = JournalService();
  AuthService authService = AuthService();

  int? userId;

  String? userToken;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Título basado no dia atual
        title: Text(
          "${currentDay.day}  |  ${currentDay.month}  |  ${currentDay.year}",
        ),
        actions: [
          IconButton(onPressed: refresh, icon: const Icon(Icons.refresh))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              onTap: () => logout(context),
              title: const Text('Sair'),
              leading: const Icon(Icons.logout),
            )
          ],
        ),
      ),
      body: (userId != null && userToken != null)
          ? ListView(
              controller: _listScrollController,
              children: generateListJournalCards(
                  userId: userId!,
                  windowPage: windowPage,
                  currentDay: currentDay,
                  refreshFunction: refresh,
                  database: database,
                  token: userToken!),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void refresh() {
    SharedPreferences.getInstance().then((prefs) {
      String? token = prefs.getString("accessToken");
      String? email = prefs.getString("email");
      int? id = prefs.getInt("id");
      if (token != null && email != null && id != null) {
        setState(() {
          userId = id;
          userToken = token;
        });
        try {
          journalService
              .getAll(id: id.toString(), token: token)
              .then((List<Journal> journalsList) {
            setState(() {
              database = {};
              for (final journal in journalsList) {
                database[journal.id] = journal;
              }
            });
          });
        } catch (e) {
          authService.clearUserInfo();
          Navigator.pushReplacementNamed(context, 'login');
        }
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    }).catchError(
      (error) {
        logout(context);
      },
      test: (error) => error is InvalidTokenException,
    ).catchError((error) {
      showExceptionDialog(context, content: (error as HttpException).message);
    }, test: ((error) => error is HttpException));
  }
}
