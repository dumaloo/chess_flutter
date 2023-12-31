import 'package:chess_flutter/components/square.dart';
import 'package:chess_flutter/helper/helper_methods.dart';
import 'package:chess_flutter/values/colors.dart';
import 'package:flutter/material.dart';
import 'components/piece.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // A 2-D list representing the chessboard,
  //with each position possibly containing a chess piece

  late List<List<ChessPiece?>> board;

  //The currently selected piece on the chess board
  //if no piece selected then null
  ChessPiece? selectedPiece;

  //The row index of the selected piece
  //Default value -1 indicated no piece is currently selected
  int selectedRow = -1;

  //The col  index of the selected piece
  //Default value -1 indicated no piece is currently selected
  int selectedCol = -1;

  //Identify List of Valid Moves for currently selected piece
  //each move is represented as a list with 2 elements: row and col
  List<List<int>> validMoves = [];

  // A list of white pieces that have been taken by the black player
  List<ChessPiece> whitePiecestaken = [];

  // A list of black pieces that have been taken by the white player
  List<ChessPiece> blackPiecestaken = [];

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  //INITIALIZE BOARD

  void _initializeBoard() {
    //initialize the board with nulls, meaning no pieces in those positions
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    //Place Pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: false,
        imagePath: 'images/pawn.png',
      );
      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
        imagePath: 'images/pawn.png',
      );
    }

    //Place rooks
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'images/rook.png',
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'images/rook.png',
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'images/rook.png',
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'images/rook.png',
    );

    //Place Bishops
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'images/bishop.png',
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'images/bishop.png',
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'images/bishop.png',
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'images/bishop.png',
    );

    //Place Knights
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'images/knight.png',
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'images/knight.png',
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'images/knight.png',
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'images/knight.png',
    );

    //Place Queens
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: 'images/queen.png',
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: 'images/queen.png',
    );

    //Place Kings
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: 'images/king.png',
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: 'images/king.png',
    );

    board = newBoard;
  }

  //USER SELECTED A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // No piece has been selected yet, this is the first selection
      if (selectedPiece == null && board[row][col] != null) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      // There is a piece already selected, but user can select another one of their pieces
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      //if there is a piece selected and user taps on a sqaure that is a valid move, move there
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      //if a piece is selected calculate its valid moves
      validMoves =
          calculateRawValidMoves(selectedRow, selectedCol, selectedPiece);
    });
  }

  //CALCULATE RAW VALID MOVES
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    //different directions based on their color
    int direction = piece!.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        //pawns can move forward if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        //pawns can move 2 squares forward if they are at their initial positions
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        //pawns can capture diagonally
        //left diagonal
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        //right diagonal
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:
        //horizontal and vertical directions
        var directions = [
          [-1, 0], //up
          [1, 0], // down
          [0, -1], //left
          [0, 1], //right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //Kill it
              }
              break; //blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        //all eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1], //up 2 left 1
          [-2, 1], //up 2 right 1
          [-1, -2], //up 1 left 2
          [-1, 2], //up 1 right 2
          [1, -2], //down 1 left 2
          [1, 2], //down 1 right 2
          [2, -1], //down 2 left 1
          [2, 1], //down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); //capture
            }
            continue; //blocked
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      case ChessPieceType.bishop:
        //diagonal directions
        var directions = [
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //capture
              }
              break; //block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        // all eight directions: up, down, left, right and 4 diagonals
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            break;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); //capture
            }
            break; //blocked
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.queen:
        // all eight directions: up, down, left, right and 4 diagonals
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //capture
              }
              break; //block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      default:
    }
    return candidateMoves;
  }

  //MOVE PIECE
  void movePiece(int newRow, int newCol) {
    // if the new spot has an enemy piece
    if (board[newRow][newCol] != null) {
      //add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecestaken.add(capturedPiece);
      } else {
        blackPiecestaken.add(capturedPiece);
      }
    }

    //move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    //clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          //WHITE PIECES TAKEN
          // Expanded(child: child),

          Expanded(
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) {
                // get the row and col position of this square
                int row = index ~/ 8;
                int col = index % 8;

                //check if this square is selected or not
                bool isSelected = selectedRow == row && selectedCol == col;

                //check if this square is a valid move
                bool isValidMove = false;
                for (var position in validMoves) {
                  //compare row and col
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  onTap: () => pieceSelected(row, col),
                  isValidMove: isValidMove,
                );
              },
            ),
          ),

          //BLACK PIECES TAKEN
          // Expanded(child: child),
        ],
      ),
    );
  }
}
