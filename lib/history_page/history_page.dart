import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/utils.dart';
import '../replay_page/replay_page.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final historyBox = Hive.box('game_history');
    return Scaffold(
      appBar: AppBar(
        title: Text('Game History'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            tooltip: 'ลบประวัติทั้งหมด',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('ลบประวัติทั้งหมด?'),
                  content: Text('แน่ใจหรือไม่ว่าต้องการล้างประวัติทั้งหมด?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text('ยกเลิก'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text('ลบ', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await historyBox.clear();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('ลบประวัติเกมทั้งหมดแล้ว')));
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: historyBox.listenable(),
        builder: (context, box, _) {
          final games = box.values.toList();
          if (games.isEmpty) {
            return Center(child: Text('No games played yet.'));
          }
          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, idx) {
              final history = castHistory(games[idx]);
              final lastBoard = history.last;
              String result = calculateResult(lastBoard);

              return ListTile(
                leading: Text('#${idx + 1}'),
                title: Text('Result: $result'),
                subtitle: Text('Tap to replay'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  tooltip: 'ลบประวัติเกมนี้',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('ลบประวัติเกมนี้?'),
                        content: Text('ต้องการลบประวัติเกมนี้หรือไม่?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text('ยกเลิก'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child:
                                Text('ลบ', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await historyBox.deleteAt(idx);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ลบประวัติเกมเรียบร้อย')));
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReplayPage(history: history, gameIndex: idx),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
