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
  bool playerStarts = true;
  bool isGameStarted = false;

  void _startGame(bool playerFirst) {
    setState(() {
      playerStarts = playerFirst;
      isGameStarted = true;
      board = List.generate(9, (index) => '');
      winner = '';
      gameOver = false;
      if (!playerFirst) {
        _aiMove();
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
    int bestVal = -1000;
    int bestMove = -1;

    for (int i = 0; i < board.length; i++) {
      // Check if cell is empty
      if (board[i] == '') {
        // Make the move
        board[i] = 'O';
        // Compute evaluation function for this move.
        int moveVal = _minimax(false);
        // Undo the move
        board[i] = '';
        // If the value of the current move is more than the best value, then update best
        if (moveVal > bestVal) {
          bestMove = i;
          bestVal = moveVal;
        }
      }
    }

    if (bestMove != -1) {
      board[bestMove] = 'O';
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
      if (!playerStarts) {
        _aiMove();
      }
    });
  }

  void _backToMainMenu() {
    setState(() {
      isGameStarted = false;
    });
  }

  int _evaluateBoard() {
    // Checking for Rows for X or O victory.
    for (int row = 0; row < 3; row++) {
      if (board[row * 3] == board[row * 3 + 1] &&
          board[row * 3 + 1] == board[row * 3 + 2]) {
        if (board[row * 3] == 'O')
          return 10;
        else if (board[row * 3] == 'X') return -10;
      }
    }

    // Checking for Columns for X or O victory.
    for (int col = 0; col < 3; col++) {
      if (board[col] == board[col + 3] && board[col + 3] == board[col + 6]) {
        if (board[col] == 'O')
          return 10;
        else if (board[col] == 'X') return -10;
      }
    }

    // Checking for Diagonals for X or O victory.
    if (board[0] == board[4] && board[4] == board[8]) {
      if (board[0] == 'O')
        return 10;
      else if (board[0] == 'X') return -10;
    }
    if (board[2] == board[4] && board[4] == board[6]) {
      if (board[2] == 'O')
        return 10;
      else if (board[2] == 'X') return -10;
    }

    // Else if none of them have won then return 0
    return 0;
  }

  int _minimax(bool isMax) {
    int score = _evaluateBoard();

    // If Maximizer has won the game return their evaluated score
    if (score == 10) return score;

    // If Minimizer has won the game return their evaluated score
    if (score == -10) return score;

    // If there are no more moves and no winner then it is a tie
    if (!board.contains('')) return 0;

    if (isMax) {
      int best = -1000;
      for (int i = 0; i < board.length; i++) {
        // Check if cell is empty
        if (board[i] == '') {
          // Make the move
          board[i] = 'O';
          // Call minimax recursively and choose the maximum value
          best = max(best, _minimax(!isMax));
          // Undo the move
          board[i] = '';
        }
      }
      return best;
    } else {
      int best = 1000;
      for (int i = 0; i < board.length; i++) {
        // Check if cell is empty
        if (board[i] == '') {
          // Make the move
          board[i] = 'X';
          // Call minimax recursively and choose the minimum value
          best = min(best, _minimax(!isMax));
          // Undo the move
          board[i] = '';
        }
      }
      return best;
    }
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
    return MaterialApp(
      restorationScopeId: "Test",
      home: Scaffold(
        // Removing the AppBar
        body: !isGameStarted
            ? Center(
                // Main menu with title
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Tic Tac Toe',
                      style: TextStyle(
                        fontSize: 48.0, // Large font size for the title
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Color of the title
                      ),
                    ),
                    SizedBox(height: 20), // Spacing between title and buttons
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => _startGame(true),
                        child: Text('Player Starts'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => _startGame(false),
                        child: Text('AI Starts'),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (winner.isNotEmpty) ...[
                    Expanded(
                      // Centering the end-game screen
                      child: Center(
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min, // Aligns children to the center
                          children: [
                            Text(
                              winner,
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: _resetGame,
                                child: Text('Restart Game'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: _backToMainMenu,
                                child: Text('Back to Main Menu'),
                              ),
                            ),
                          ],
                        ),
                      ),
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
      ),
    );
  }
}
