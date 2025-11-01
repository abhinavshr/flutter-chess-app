class ChessPieces {
  static String getUnicode(String p) {
    bool white = p.startsWith('w');
    String type = p[1].toUpperCase();

    const map = {
      'K': 0x2654,
      'Q': 0x2655,
      'R': 0x2656,
      'B': 0x2657,
      'N': 0x2658,
      'P': 0x2659,
    };

    int base = map[type] ?? 0x2659;
    if (!white) base += 6;

    return String.fromCharCode(base);
  }
}
