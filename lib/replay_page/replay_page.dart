import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../utils/utils.dart';

class ReplayPage extends StatelessWidget {
  final List<List<List<String>>> history;
  final int gameIndex;

  const ReplayPage({required this.history, required this.gameIndex, Key? key})
      : super(key: key);

  void deleteThisHistory(BuildContext context) async {
    final historyBox = Hive.box('game_history');
    await historyBox.deleteAt(gameIndex);
    Navigator.pop(context); // กลับไปหน้า History
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('History deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    int step = 0;
    return StatefulBuilder(
      builder: (context, setState) => Scaffold(
        appBar: AppBar(
          title: Text('Replay'),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final bool? shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Delete this history?'),
                    content:
                        Text('Are you sure you want to delete this history?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child:
                            Text('Delete', style: TextStyle(color: Colors.red)),
                      )
                    ],
                  ),
                );
                if (shouldDelete == true) {
                  deleteThisHistory(context);
                }
              },
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Result: ${calculateResult(history.last)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
                itemCount: history[0].length * history[0].length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: history[0].length,
                ),
                itemBuilder: (context, index) {
                  final row = index ~/ history[0].length;
                  final col = index % history[0].length;
                  return Container(
                    margin: EdgeInsets.all(4),
                    color: Colors.green.shade100,
                    child: Center(
                      child: Text(
                        history[step][row][col],
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
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
                  child: Text('Back'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: step < history.length - 1
                      ? () => setState(() => step++)
                      : null,
                  child: Text('Next'),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
