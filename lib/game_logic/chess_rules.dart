class Move {
  final int fr, fc, tr, tc;
  final String moved;
  final String? captured;
  final bool whiteTurn;

  Move(this.fr, this.fc, this.tr, this.tc, this.moved, this.captured, this.whiteTurn);
}

class ChessGame {
  late List<List<String?>> board;
  bool whiteTurn = true;
  int? selectedRow;
  int? selectedCol;
  List<List<int>> highlightedMoves = [];
  List<Move> history = [];

  ChessGame() {
    reset();
  }

  void reset() {
    board = List.generate(8, (_) => List.filled(8, null));
    board[0] = ['bR','bN','bB','bQ','bK','bB','bN','bR'];
    board[1] = List.filled(8, 'bP');
    board[6] = List.filled(8, 'wP');
    board[7] = ['wR','wN','wB','wQ','wK','wB','wN','wR'];
    for (int i = 2; i < 6; i++) board[i] = List.filled(8, null);
    whiteTurn = true;
    highlightedMoves = [];
    selectedRow = selectedCol = null;
    history.clear();
  }

  void onTap(int r, int c) {
    String? piece = board[r][c];
    if (selectedRow == null) {
      if (piece == null) return;
      if (whiteTurn && !piece.startsWith('w')) return;
      if (!whiteTurn && !piece.startsWith('b')) return;

      selectedRow = r;
      selectedCol = c;
      highlightedMoves = generateMoves(r, c).where((m) {
        String? captured = board[m[0]][m[1]];
        board[m[0]][m[1]] = board[r][c];
        board[r][c] = null;
        bool safe = !isKingInCheck(whiteTurn);
        board[r][c] = board[m[0]][m[1]];
        board[m[0]][m[1]] = captured;
        return safe;
      }).toList();
      return;
    }

    if (selectedRow == r && selectedCol == c) {
      selectedRow = selectedCol = null;
      highlightedMoves = [];
      return;
    }

    bool validMove = highlightedMoves.any((m) => m[0] == r && m[1] == c);
    if (validMove) {
      movePiece(selectedRow!, selectedCol!, r, c);
      if (isKingInCheck(!whiteTurn)) {
        if (isCheckmate(!whiteTurn)) {}
      }
    }

    selectedRow = selectedCol = null;
    highlightedMoves = [];
  }

  void movePiece(int fr, int fc, int tr, int tc) {
    String? moving = board[fr][fc];
    String? captured = board[tr][tc];
    history.add(Move(fr, fc, tr, tc, moving!, captured, whiteTurn));
    board[tr][tc] = moving;
    board[fr][fc] = null;

    if (moving.endsWith('P') && (tr == 0 || tr == 7)) board[tr][tc] = moving[0] == 'w' ? 'wQ' : 'bQ';

    whiteTurn = !whiteTurn;
  }

  void undo() {
    if (history.isEmpty) return;
    Move m = history.removeLast();
    board[m.fr][m.fc] = m.moved;
    board[m.tr][m.tc] = m.captured;
    whiteTurn = m.whiteTurn;
  }

  List<List<int>> generateMoves(int r, int c) {
    String p = board[r][c]!;
    bool white = p.startsWith('w');
    String type = p[1].toUpperCase();
    List<List<int>> moves = [];
    bool inside(int rr, int cc) => rr >= 0 && rr < 8 && cc >= 0 && cc < 8;
    bool enemy(int rr, int cc) => inside(rr, cc) && board[rr][cc] != null && board[rr][cc]!.startsWith(white ? 'b' : 'w');
    bool empty(int rr, int cc) => inside(rr, cc) && board[rr][cc] == null;

    if (type == 'P') {
      int dir = white ? -1 : 1;
      if (empty(r + dir, c)) moves.add([r + dir, c]);
      if ((white && r == 6) || (!white && r == 1)) if (empty(r+dir,c) && empty(r+2*dir,c)) moves.add([r+2*dir,c]);
      for (int dc in [-1,1]) if (enemy(r+dir, c+dc)) moves.add([r+dir, c+dc]);
    }

    if (type == 'N') {
      List<List<int>> jump = [[2,1],[2,-1],[-2,1],[-2,-1],[1,2],[1,-2],[-1,2],[-1,-2]];
      for (var d in jump) {
        int rr=r+d[0], cc=c+d[1];
        if (!inside(rr,cc)) continue;
        if (empty(rr,cc) || enemy(rr,cc)) moves.add([rr,cc]);
      }
    }

    List<List<int>> dirs = [];
    if (type == 'B' || type == 'Q') dirs.addAll([[1,1],[1,-1],[-1,1],[-1,-1]]);
    if (type == 'R' || type == 'Q') dirs.addAll([[1,0],[-1,0],[0,1],[0,-1]]);
    for (var d in dirs) {
      int rr=r+d[0], cc=c+d[1];
      while (inside(rr,cc)) {
        if (empty(rr,cc)) moves.add([rr,cc]);
        else {
          if (enemy(rr,cc)) moves.add([rr,cc]);
          break;
        }
        rr+=d[0]; cc+=d[1];
      }
    }

    if (type == 'K') {
      for (int dr=-1; dr<=1; dr++) {
        for (int dc=-1; dc<=1; dc++) {
          if (dr==0 && dc==0) continue;
          int rr=r+dr, cc=c+dc;
          if (inside(rr,cc) && (empty(rr,cc) || enemy(rr,cc))) moves.add([rr,cc]);
        }
      }
    }

    return moves;
  }

  bool isKingInCheck(bool white) {
    int kr=-1, kc=-1;
    for (int r=0; r<8; r++) for (int c=0; c<8; c++) if (board[r][c] == (white?'wK':'bK')) { kr=r; kc=c; break; }
    for (int r=0; r<8; r++) {
      for (int c=0; c<8; c++) {
        String? p = board[r][c];
        if (p==null) continue;
        if (p.startsWith(white?'b':'w')) {
          for (var m in generateMoves(r,c)) if (m[0]==kr && m[1]==kc) return true;
        }
      }
    }
    return false;
  }

  bool isCheckmate(bool white) {
    if (!isKingInCheck(white)) return false;
    for (int r=0; r<8; r++) {
      for (int c=0; c<8; c++) {
        String? p = board[r][c];
        if (p==null) continue;
        if ((white && p.startsWith('w')) || (!white && p.startsWith('b'))) {
          for (var m in generateMoves(r,c)) {
            String? captured = board[m[0]][m[1]];
            board[m[0]][m[1]] = board[r][c];
            board[r][c] = null;
            bool safe = !isKingInCheck(white);
            board[r][c] = board[m[0]][m[1]];
            board[m[0]][m[1]] = captured;
            if (safe) return false;
          }
        }
      }
    }
    return true;
  }
}
