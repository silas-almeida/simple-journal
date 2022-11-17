import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_journal/models/journal.dart';
import 'package:simple_journal/screens/add_journal_screen/add_journal_screen.dart';
import 'package:simple_journal/screens/login_screen/login_screen.dart';
import 'screens/home_screen/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MyApp(
      isLogged: await verifyToken(),
    ),
  );
}

Future<bool> verifyToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("token");
  return token != null;
}

class MyApp extends StatelessWidget {
  final bool isLogged;
  const MyApp({Key? key, required this.isLogged}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Journal',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            titleTextStyle: TextStyle(color: Colors.white),
            elevation: 0.0,
            iconTheme: IconThemeData(
              color: Colors.white,
            )),
        textTheme: GoogleFonts.bitterTextTheme(),
      ),
      initialRoute: isLogged ? "login" : "home",
      routes: {
        "home": (context) => const HomeScreen(),
        "login": (context) => LoginScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == "add-journal") {
          Map<String, dynamic> map = settings.arguments as Map<String, dynamic>;
          final Journal journal = map["journal"] as Journal;
          final bool isEditing = map["is_editing"] as bool;

          return MaterialPageRoute(
              builder: ((context) => AddJournalScreen(
                    journal: journal,
                    isEditing: isEditing,
                  )));
        }
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      },
    );
  }
}
