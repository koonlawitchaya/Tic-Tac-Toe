import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

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
            tooltip: 'Delete All History',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Delete All History?'),
                  content: Text(
                      'You are about to delete all game history. This action cannot be undone. Do you want to proceed?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child:
                          Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await historyBox.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('All game history deleted successfully.')),
                );
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: historyBox.listenable(),
        builder: (context, Box box, _) {
          // สร้างรายการที่มีข้อมูลจำเป็น {key, history, timestamp}
          final items = box.keys
              .cast()
              .map((key) {
                final data = box.get(key);
                if (data is Map &&
                    data.containsKey('history') &&
                    data.containsKey('timestamp')) {
                  final history = castHistory(data['history']);
                  DateTime? timestamp;
                  if (data['timestamp'] is DateTime) {
                    timestamp = data['timestamp'];
                  } else if (data['timestamp'] is String) {
                    timestamp = DateTime.tryParse(data['timestamp']);
                  }
                  return {
                    'key': key,
                    'history': history,
                    'timestamp': timestamp,
                  };
                }
                return null;
              })
              .where((e) => e != null && e['timestamp'] != null)
              .toList();

          // ** sort by timestamp (ใหม่ก่อน) **
          items.sort((a, b) => b!['timestamp'].compareTo(a!['timestamp']));

          if (items.isEmpty) {
            return Center(child: Text('No games played yet.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final game = items[i]!;
              final key = game['key'];
              final history = game['history'];
              final timestamp = game['timestamp'] as DateTime;
              final lastBoard = history.last;
              final result = calculateResult(lastBoard);

              final formattedTime =
                  DateFormat('yyyy-MM-dd HH:mm').format(timestamp);

              return ListTile(
                leading: Icon(Icons.history),
                title: Text('Result: $result'),
                subtitle: Text('Played on $formattedTime'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete Game History',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Delete Game History?'),
                        content: Text(
                            'Are you sure you want to delete this game history?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await historyBox.delete(key);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Game history deleted successfully.')),
                      );
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReplayPage(history: history, gameIndex: key),
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
