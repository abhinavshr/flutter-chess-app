import 'package:flutter/material.dart';
import 'game_logic/pieces.dart';

class ChessBoardScreen extends StatefulWidget {
  @override
  State<ChessBoardScreen> createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  List<List<String?>> board = List.generate(8, (_) => List.filled(8, null));
  bool whiteTurn = true;

  int? selectedRow;
  int? selectedCol;
  List<List<int>> highlightedMoves = [];

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  void _initBoard() {
    board[0] = ['bR','bN','bB','bQ','bK','bB','bN','bR'];
    board[1] = List.filled(8, 'bP');
    board[6] = List.filled(8, 'wP');
    board[7] = ['wR','wN','wB','wQ','wK','wB','wN','wR'];
    for (int r = 2; r <= 5; r++) {
      board[r] = List.filled(8, null);
    }
    selectedRow = null;
    selectedCol = null;
    highlightedMoves = [];
    whiteTurn = true;
  }

  List<List<int>> _dummyHighlightMoves(int r, int c) {
    List<List<int>> moves = [];
    String? piece = board[r][c];
    if (piece == null) return moves;

    bool isWhite = piece.startsWith('w');
    if (piece[1] == 'P') {
      int dir = isWhite ? -1 : 1;
      int newRow = r + dir;
      if (newRow >= 0 && newRow <= 7 && board[newRow][c] == null) {
        moves.add([newRow, c]);
      }
    }
    return moves;
  }

  void _onTap(int r, int c) {
    setState(() {
      String? tappedPiece = board[r][c];

      if (tappedPiece != null &&
          ((whiteTurn && tappedPiece.startsWith('w')) ||
              (!whiteTurn && tappedPiece.startsWith('b')))) {
        selectedRow = r;
        selectedCol = c;
        highlightedMoves = _dummyHighlightMoves(r, c);
      } else if (highlightedMoves.any((m) => m[0] == r && m[1] == c)) {
        board[r][c] = board[selectedRow!][selectedCol!];
        board[selectedRow!][selectedCol!] = null;
        selectedRow = null;
        selectedCol = null;
        highlightedMoves = [];
        whiteTurn = !whiteTurn;
      } else {
        selectedRow = null;
        selectedCol = null;
        highlightedMoves = [];
      }
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
          bool selected = selectedRow == r && selectedCol == c;
          bool highlight = highlightedMoves.any((m) => m[0] == r && m[1] == c);

          Color color = isLight ? Colors.brown.shade200 : Colors.brown.shade700;
          if (selected) color = Colors.green.withOpacity(0.6);
          else if (highlight) color = Colors.greenAccent.withOpacity(0.35);

          String? piece = board[r][c];

          return GestureDetector(
            onTap: () => _onTap(r, c),
            child: Container(
              color: color,
              child: Center(
                child: Text(
                  piece != null ? ChessPieces.getUnicode(piece) : '',
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
              onPressed: () {}, // Add undo logic later
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Reset"),
              onPressed: () => setState(_initBoard),
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
