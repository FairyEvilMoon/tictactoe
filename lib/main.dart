import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TicTacToePage(),
    );
  }
}

class TicTacToePage extends StatefulWidget {
  @override
  _TicTacToePageState createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  List<String> board = List.generate(9, (index) => '');
  String winner = '';
  bool gameOver = false;
  bool playerStarts = true; // New variable to track who starts
  bool isGameStarted = false; // Track if the game has started

  void _startGame(bool playerFirst) {
    setState(() {
      playerStarts = playerFirst;
      isGameStarted = true;
      if (!playerFirst) {
        _aiMove(); // AI makes the first move
      }
    });
  }

  void _handleTap(int index) {
    if (board[index] != '' || gameOver) return;
    setState(() {
      board[index] = 'X';
      _checkGameState();
      if (!gameOver) {
        _aiMove();
        _checkGameState();
      }
    });
  }

  void _aiMove() {
    var emptySpots =
        List.generate(9, (i) => i).where((i) => board[i] == '').toList();
    if (emptySpots.isNotEmpty) {
      final randomIndex = Random().nextInt(emptySpots.length);
      board[emptySpots[randomIndex]] = 'O';
    }
  }

  void _checkGameState() {
    if (_checkWinner('X')) {
      winner = 'Player wins!';
      gameOver = true;
    } else if (_checkWinner('O')) {
      winner = 'AI wins!';
      gameOver = true;
    } else if (!board.contains('')) {
      winner = 'It\'s a Draw!';
      gameOver = true;
    }
  }

  bool _checkWinner(String player) {
    const winningPatterns = [
      {0, 1, 2},
      {3, 4, 5},
      {6, 7, 8},
      {0, 3, 6},
      {1, 4, 7},
      {2, 5, 8},
      {0, 4, 8},
      {2, 4, 6}
    ];

    for (var pattern in winningPatterns) {
      if (pattern.every((index) => board[index] == player)) {
        return true;
      }
    }
    return false;
  }

  void _resetGame() {
    setState(() {
      board = List.generate(9, (index) => '');
      winner = '';
      gameOver = false;
    });
  }

  Widget _buildCell(int index) {
    return GestureDetector(
      onTap: () => _handleTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          border: Border.all(color: Colors.black),
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            board[index],
            key: ValueKey<String>(board[index]),
            style: TextStyle(
              fontSize: 64.0,
              color: board[index] == 'X' ? Colors.white : Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
      ),
      body: !isGameStarted
          ? Center(
              // Start game options
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Who starts first?', style: TextStyle(fontSize: 24)),
                  ElevatedButton(
                    onPressed: () => _startGame(true),
                    child: Text('Player Starts'),
                  ),
                  ElevatedButton(
                    onPressed: () => _startGame(false),
                    child: Text('AI Starts'),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (winner.isNotEmpty) ...[
                  Text(
                    winner,
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _resetGame,
                    child: Text('Restart Game'),
                  )
                ] else ...[
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: 9,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      return _buildCell(index);
                    },
                  ),
                ],
              ],
            ),
    );
  }
}
