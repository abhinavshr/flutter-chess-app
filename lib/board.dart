import 'package:flutter/material.dart';
import 'game_logic/pieces.dart';
import 'game_logic/chess_rules.dart';

class ChessBoardScreen extends StatefulWidget {
  @override
  State<ChessBoardScreen> createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  late ChessGame game;

  @override
  void initState() {
    super.initState();
    game = ChessGame();
  }

  Widget buildBoard() {
    bool whiteInCheck = game.isKingInCheck(true);
    bool blackInCheck = game.isKingInCheck(false);

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        itemCount: 64,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemBuilder: (context, index) {
          int r = index ~/ 8;
          int c = index % 8;
          bool isLight = (r + c) % 2 == 0;
          bool selected = game.selectedRow == r && game.selectedCol == c;
          bool highlight = game.highlightedMoves.any((m) => m[0]==r && m[1]==c);
          String? piece = game.board[r][c];

          Color color = isLight ? Colors.brown.shade200 : Colors.brown.shade700;

          if (selected) {
            color = Colors.green.withOpacity(0.6);
          } else if (highlight) {
            color = Colors.greenAccent.withOpacity(0.35);
          }

          // Highlight king in check
          if (piece == 'wK' && whiteInCheck) color = Colors.red.withOpacity(0.8);
          if (piece == 'bK' && blackInCheck) color = Colors.red.withOpacity(0.8);

          return GestureDetector(
            onTap: () {
              setState(() {
                game.onTap(r, c);
              });
            },
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
    bool whiteInCheck = game.isKingInCheck(true);
    bool blackInCheck = game.isKingInCheck(false);
    bool whiteCheckmate = game.isCheckmate(true);
    bool blackCheckmate = game.isCheckmate(false);

    String status = "";
    if (whiteCheckmate) status = "Black Wins by Checkmate!";
    else if (blackCheckmate) status = "White Wins by Checkmate!";
    else if (whiteInCheck) status = "White in Check!";
    else if (blackInCheck) status = "Black in Check!";
    else status = game.whiteTurn ? "White's Turn" : "Black's Turn";

    return Column(
      children: [
        Text(
          status,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.undo),
              label: const Text("Undo"),
              onPressed: () {
                if (!whiteCheckmate && !blackCheckmate) {
                  setState(() => game.undo());
                }
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Restart"),
              onPressed: () {
                setState(() => game.reset());
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
        ),
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
