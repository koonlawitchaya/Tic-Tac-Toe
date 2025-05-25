import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tictactoe/game_setup_screen/game_setup_screen.dart';
import 'game_page/game_page.dart';
import 'history_page/history_page.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('game_history');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XO Game',
      routes: {
        '/': (context) => GameSetupScreen(),
        '/game': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return GamePage(
            boardSize: args['boardSize'],
            playWithBot: args['playWithBot'],
            difficulty: args['difficulty'],
          );
        },
        '/history': (context) => HistoryPage(),
      },
      initialRoute: '/',
    );
  }
}
