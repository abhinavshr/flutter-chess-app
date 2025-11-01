import 'package:flutter/material.dart';

class ChessBoardScreen extends StatefulWidget {
  @override
  State<ChessBoardScreen> createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  List<List<String?>> board = List.generate(8, (_) => List.filled(8, null));
  bool whiteTurn = true;

  @override
  void initState() {
    super.initState();
    _initDummyBoard();
  }

  void _initDummyBoard() {
    board[1] = List.filled(8, "♟");
    board[6] = List.filled(8, "♙");
    board[0][0] = board[0][7] = "♜";
    board[7][0] = board[7][7] = "♖";
  }

  void _onTap(int r, int c) {
    setState(() {
      whiteTurn = !whiteTurn;
    });
  }

  Widget buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        itemCount: 64,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) {
          int r = index ~/ 8;
          int c = index % 8;
          bool isLight = (r + c) % 2 == 0;
          Color color = isLight ? Colors.brown.shade200 : Colors.brown.shade700;
          String? piece = board[r][c];

          return GestureDetector(
            onTap: () => _onTap(r, c),
            child: Container(
              color: color,
              child: Center(
                child: Text(
                  piece ?? '',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildControls() {
    return Column(
      children: [
        Text(
          whiteTurn ? "White's Turn" : "Black's Turn",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.undo),
              label: const Text("Undo"),
              onPressed: () {},
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Reset"),
              onPressed: () {
                setState(() {
                  _initDummyBoard();
                  whiteTurn = true;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          title: const Text(
            "Flutter Chess",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          )
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildBoard(),
            ),
          ),
          const SizedBox(height: 8),
          buildControls(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
