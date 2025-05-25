import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:math';
import '../history_page/history_page.dart';
import '../utils/utils.dart';

enum Difficulty { easy, medium }

class GamePage extends StatefulWidget {
  final int boardSize;
  final bool playWithBot;
  final Difficulty difficulty;

  const GamePage({
    Key? key,
    required this.boardSize,
    required this.playWithBot,
    required this.difficulty,
  }) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late List<List<String>> board;
  late int boardSize;
  late bool playWithBot;
  late Difficulty difficulty;

  String currentPlayer = "X";
  bool gameOver = false;
  String winner = "";
  List<List<List<String>>> gameHistory = [];
  List<Point<int>> winCells = [];

  @override
  void initState() {
    super.initState();
    boardSize = widget.boardSize;
    playWithBot = widget.playWithBot;
    difficulty = widget.difficulty;
    resetBoard();
  }

  void resetBoard() {
    board = List.generate(boardSize, (_) => List.filled(boardSize, ""));
    currentPlayer = "X";
    gameOver = false;
    winner = "";
    gameHistory.clear();
    winCells.clear();
    setState(() {});
    if (playWithBot && currentPlayer == "O") botMove();
  }

  void saveGameToHistory() async {
    final historyBox = Hive.box('game_history');
    await historyBox.add({
      'history': gameHistory
          .map((b) => b.map((r) => List<String>.from(r)).toList())
          .toList(),
      'timestamp': DateTime.now().toIso8601String(),
      'playWithBot': playWithBot,
      'difficulty': difficulty.toString().split('.').last,
    });
  }

  void botMove() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (gameOver) return;

    Point<int>? move;
    if (difficulty == Difficulty.easy) {
      move = getRandomMove();
    } else {
      move = getMediumBotMove();
    }

    if (move != null) {
      setState(() {
        board[move!.x][move.y] = "O";
        gameHistory.add(_cloneBoard());
        checkWinner();
        currentPlayer = "X";
        if (gameOver) saveGameToHistory();
      });
    }
  }

  Point<int>? getRandomMove() {
    List<Point<int>> emptyCells = [];
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j] == "") emptyCells.add(Point(i, j));
      }
    }
    if (emptyCells.isNotEmpty) {
      return emptyCells[Random().nextInt(emptyCells.length)];
    }
    return null;
  }

  Point<int>? getMediumBotMove() {
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j] == "") {
          board[i][j] = "O";
          if (checkPotentialWin("O")) {
            board[i][j] = "";
            return Point(i, j);
          }
          board[i][j] = "";
        }
      }
    }
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j] == "") {
          board[i][j] = "X";
          if (checkPotentialWin("X")) {
            board[i][j] = "";
            return Point(i, j);
          }
          board[i][j] = "";
        }
      }
    }
    return getRandomMove();
  }

  bool checkPotentialWin(String player) {
    for (int i = 0; i < boardSize; i++) {
      if (board[i].where((cell) => cell == player).length == boardSize)
        return true;
      if (List.generate(boardSize, (j) => board[j][i])
              .where((cell) => cell == player)
              .length ==
          boardSize) return true;
    }
    if (List.generate(boardSize, (i) => board[i][i])
            .where((cell) => cell == player)
            .length ==
        boardSize) return true;
    if (List.generate(boardSize, (i) => board[i][boardSize - 1 - i])
            .where((cell) => cell == player)
            .length ==
        boardSize) return true;
    return false;
  }

  void checkWinner() {
    winCells.clear();
    for (int i = 0; i < boardSize; i++) {
      if (board[i].every((cell) => cell == currentPlayer)) {
        winner = currentPlayer;
        gameOver = true;
        winCells = [for (int j = 0; j < boardSize; j++) Point(i, j)];
        return;
      }
    }
    for (int i = 0; i < boardSize; i++) {
      if (List.generate(boardSize, (j) => board[j][i])
          .every((cell) => cell == currentPlayer)) {
        winner = currentPlayer;
        gameOver = true;
        winCells = [for (int j = 0; j < boardSize; j++) Point(j, i)];
        return;
      }
    }
    if (List.generate(boardSize, (i) => board[i][i])
        .every((cell) => cell == currentPlayer)) {
      winner = currentPlayer;
      gameOver = true;
      winCells = [for (int k = 0; k < boardSize; k++) Point(k, k)];
      return;
    }
    if (List.generate(boardSize, (i) => board[i][boardSize - 1 - i])
        .every((cell) => cell == currentPlayer)) {
      winner = currentPlayer;
      gameOver = true;
      winCells = [
        for (int k = 0; k < boardSize; k++) Point(k, boardSize - 1 - k)
      ];
      return;
    }
    if (board.every((row) => row.every((cell) => cell != ""))) {
      winner = "Draw";
      gameOver = true;
      winCells.clear();
    }
  }

  void handleTap(int row, int col) {
    if (board[row][col] != "" || gameOver) return;
    if (playWithBot && currentPlayer != "X") return;

    setState(() {
      board[row][col] = currentPlayer;
      gameHistory.add(_cloneBoard());
      checkWinner();
      if (!gameOver) {
        currentPlayer = currentPlayer == "X" ? "O" : "X";
        if (playWithBot && currentPlayer == "O") {
          botMove();
        }
      } else {
        saveGameToHistory();
      }
    });
  }

  List<List<String>> _cloneBoard() =>
      board.map((r) => List<String>.from(r)).toList();

  void changeBoardSize(int size) {
    setState(() {
      boardSize = size;
      gameHistory.clear();
      resetBoard();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Board size changed to $size x $size')),
    );
  }

  void changeDifficulty(Difficulty level) {
    setState(() {
      difficulty = level;
      gameHistory.clear();
      resetBoard();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(level == Difficulty.easy
            ? "Difficulty: Easy"
            : "Difficulty: Medium"),
      ),
    );
  }

  void showReplay() async {
    final historyBox = Hive.box('game_history');
    final games = historyBox.values.toList();
    if (games.isEmpty) return;
    final history = castHistory(games.last);
    final lastIndex = games.length - 1;
    Navigator.pushNamed(context, '/replay', arguments: {
      'history': history,
      'gameIndex': lastIndex,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        title: Text(
          'Tic Tac Toe ! ($boardSize x $boardSize)',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.lightBlue[200],
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Column(
            children: [
              Text(
                gameOver
                    ? (winner == "Draw" ? "It's a draw!" : "$winner wins!")
                    : "$currentPlayer's Turn",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 8),
              Text(
                playWithBot
                    ? 'Playing with: Bot (${difficulty == Difficulty.easy ? "Easy" : "Medium"})'
                    : 'Playing with: Player',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: boardSize * boardSize,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: boardSize,
                  ),
                  itemBuilder: (context, index) {
                    final row = index ~/ boardSize;
                    final col = index % boardSize;
                    bool isWinCell =
                        gameOver && winCells.contains(Point(row, col));
                    return GestureDetector(
                      onTap: () => handleTap(row, col),
                      child: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isWinCell ? Colors.amberAccent : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: Center(
                          child: Text(
                            board[row][col],
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: board[row][col] == "X"
                                  ? Colors.redAccent
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: resetBoard,
                icon: Icon(
                  Icons.replay,
                  size: 24,
                  color: Colors.white,
                ),
                label: Text(
                  'Restart',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
