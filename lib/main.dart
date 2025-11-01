import 'package:chess/board.dart';
import 'package:flutter/material.dart';

void main() => runApp(ChessApp());

class ChessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Chess App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.brown,
      ),
      home: ChessBoardScreen(),
    );
  }
}