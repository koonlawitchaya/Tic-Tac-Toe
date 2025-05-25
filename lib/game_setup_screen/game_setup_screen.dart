import 'package:flutter/material.dart';
import 'package:tictactoe/game_page/game_page.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int boardSize = 3;
  Difficulty difficulty = Difficulty.easy;
  bool playWithBot = true;

  void startGame() {
    Navigator.pushNamed(
      context,
      '/game',
      arguments: {
        'boardSize': boardSize,
        'playWithBot': playWithBot,
        'difficulty': difficulty,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.close_rounded,
                    size: 80,
                    color: Colors.blue,
                  ),
                  Icon(
                    Icons.circle_outlined,
                    size: 60,
                    color: Colors.white,
                  )
                ],
              ),
              Text(
                'Tic Tac Toe !',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AspectRatio(
                aspectRatio: 1,
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(9, (index) {
                    final isCenter = index == 4;
                    return Center(
                      child: isCenter
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.all(40),
                                elevation: 6,
                              ),
                              onPressed: startGame,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_arrow,
                                      color: Colors.red, size: 36),
                                  SizedBox(height: 4),
                                  Text(
                                    '${boardSize} x $boardSize',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    );
                  }),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Game Setup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BoardSizeDropdown(
                      currentSize: boardSize,
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => boardSize = v);
                        }
                      },
                    ),
                    SizedBox(width: 16),
                    DropdownButton<bool>(
                      value: playWithBot,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: const [
                        DropdownMenuItem(
                          child: Text(
                            'vs Bot',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          value: true,
                        ),
                        DropdownMenuItem(
                          child: Text(
                            '2 Players',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          value: false,
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => playWithBot = v);
                        }
                      },
                    ),
                    SizedBox(width: 16),
                    if (playWithBot)
                      BotDifficultyDropdown(
                        difficulty: difficulty,
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => difficulty = v);
                          }
                        },
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/history'),
                icon: Icon(
                  Icons.history,
                  color: Colors.blue,
                ),
                label: Text(
                  'Game History',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                  // minimumSize: Size(
                  //   180,
                  //   50,
                  // ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BotDifficultyDropdown extends StatelessWidget {
  final Difficulty difficulty;
  final ValueChanged<Difficulty?> onChanged;

  const BotDifficultyDropdown({
    super.key,
    required this.difficulty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Difficulty>(
      value: difficulty,
      borderRadius: BorderRadius.circular(12),
      dropdownColor: Colors.white,
      items: const [
        DropdownMenuItem(
          value: Difficulty.easy,
          child: Text(
            'Easy',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DropdownMenuItem(
          value: Difficulty.medium,
          child: Text(
            'Medium',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class BoardSizeDropdown extends StatelessWidget {
  final int currentSize;
  final ValueChanged<int?> onChanged;

  const BoardSizeDropdown({
    super.key,
    required this.currentSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: currentSize,
      borderRadius: BorderRadius.circular(12),
      dropdownColor: Colors.white,
      items: [3, 4, 5, 6]
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                '$e x $e',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
