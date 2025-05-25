import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tictactoe/utils/utils.dart';
import 'dart:math';

class ReplayPage extends StatelessWidget {
  final List<List<List<String>>> history;
  final int gameIndex;

  const ReplayPage({
    required this.history,
    required this.gameIndex,
    Key? key,
  }) : super(key: key);

  void deleteThisHistory(BuildContext context) async {
    final historyBox = Hive.box('game_history');
    await historyBox.deleteAt(gameIndex);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Game history deleted successfully.')),
    );
  }

  List<Point<int>> getWinCells(List<List<String>> board) {
    final int size = board.length;

    for (int i = 0; i < size; i++) {
      if (board[i][0] != "" &&
          List.generate(size, (j) => board[i][j])
              .every((v) => v == board[i][0])) {
        return [for (int j = 0; j < size; j++) Point(i, j)];
      }
    }

    for (int i = 0; i < size; i++) {
      if (board[0][i] != "" &&
          List.generate(size, (j) => board[j][i])
              .every((v) => v == board[0][i])) {
        return [for (int j = 0; j < size; j++) Point(j, i)];
      }
    }

    if (board[0][0] != "" &&
        List.generate(size, (i) => board[i][i])
            .every((v) => v == board[0][0])) {
      return [for (int i = 0; i < size; i++) Point(i, i)];
    }

    if (board[0][size - 1] != "" &&
        List.generate(size, (i) => board[i][size - 1 - i])
            .every((v) => v == board[0][size - 1])) {
      return [for (int i = 0; i < size; i++) Point(i, size - 1 - i)];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    int step = 0;
    final result = calculateResult(history.last);
    final winCells = getWinCells(history.last);

    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Replay',
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  final bool? shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Delete This History'),
                      content: Text(
                          'You are about to delete this game history. This action cannot be undone. Do you want to proceed?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                  );
                  if (shouldDelete == true) {
                    deleteThisHistory(context);
                  }
                },
              ),
            ],
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 100),
            child: Column(
              children: [
                SizedBox(height: 16),
                Text(
                  'Result: $result',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: history[0].length * history[0].length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: history[0].length,
                    ),
                    itemBuilder: (context, index) {
                      final row = index ~/ history[0].length;
                      final col = index % history[0].length;
                      final isWinCell = winCells.contains(Point(row, col)) &&
                          step == history.length - 1;

                      return Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isWinCell
                              ? Colors.amberAccent
                              : Colors.blue.shade100,
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            history[step][row][col],
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: step > 0 ? () => setState(() => step--) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Back'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: step < history.length - 1
                          ? () => setState(() => step++)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Next'),
                    ),
                  ],
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}
