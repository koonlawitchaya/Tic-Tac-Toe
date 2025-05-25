// ฟังก์ชันสำหรับ cast และผลลัพธ์
List<List<List<String>>> castHistory(dynamic raw) {
  return (raw as List)
      .map<List<List<String>>>(
        (step) => (step as List)
            .map<List<String>>((row) =>
                (row as List).map<String>((cell) => cell.toString()).toList())
            .toList(),
      )
      .toList();
}

String calculateResult(List<List<String>> board) {
  int size = board.length;
  List<String> players = ['X', 'O'];
  for (var player in players) {
    for (int i = 0; i < size; i++) {
      if (board[i].every((cell) => cell == player)) return '$player wins';
      if (List.generate(size, (j) => board[j][i])
          .every((cell) => cell == player)) return '$player wins';
    }
    if (List.generate(size, (i) => board[i][i]).every((cell) => cell == player))
      return '$player wins';
    if (List.generate(size, (i) => board[i][size - 1 - i])
        .every((cell) => cell == player)) return '$player wins';
  }
  if (board.every((row) => row.every((cell) => cell != ""))) {
    return 'Draw';
  }
  return 'Incomplete';
}
