import 'package:chess/bloc/chess_board/chess_board_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/chess_board_controller.dart';
import '../features/arrow.dart';
import '../features/chess.dart' hide State;
import '../features/chess_pieces.dart';
import '../features/constants.dart';
import 'dart:math';

class ChessBoard extends StatelessWidget {
  final double? size;
  final bool enableUserMoves;
  final BoardColor boardColor;
  final PlayerColor boardOrientation;
  final VoidCallback? onMove;
  final List<BoardArrow> arrows;
  final ChessBoardController controller;

  const ChessBoard({
    super.key,
    this.size,
    this.enableUserMoves = true,
    this.boardColor = BoardColor.brown,
    this.boardOrientation = PlayerColor.white,
    this.onMove,
    this.arrows = const [], required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    Chess game = Chess();
    final ChessBoardCubit chessBoardCubit = ChessBoardCubit(game);

    return BlocConsumer<ChessBoardCubit, ChessBoardInitial>(
      bloc: chessBoardCubit,
      listener: (context, state){

      },
      builder: (context, state) {
        final game = state.chess;
        PieceMoveData? selectedSquare;
        List<int> currentLegalSquare = [];

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: _getBoardImage(boardColor),
              ),
              AspectRatio(
                aspectRatio: 1.0,
                child: _getBoardNotation(boardColor),
              ),
              AspectRatio(
                aspectRatio: 1.0,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) {
                    List<int> getLegalMoves(int squareNo) {
                      final moves = game.generate_moves();
                      return moves
                          .where((move) =>
                              move.from == squareNo && move.from != move.to)
                          .map((move) => move.to)
                          .toList();
                    }

                    var row = index ~/ 8;
                    var column = index % 8;
                    var boardRank = boardOrientation == PlayerColor.black
                        ? '${row + 1}'
                        : '${(7 - row) + 1}';
                    var boardFile = boardOrientation == PlayerColor.white
                        ? files[column]
                        : files[7 - column];

                    var squareName = '$boardFile$boardRank';
                    var pieceOnSquare = game.get(squareName);

                    var piece = BoardPiece(
                      squareName: squareName,
                      game: game,
                    );

                    var draggable = game.get(squareName) != null
                        ? InkWell(
                            onTap: () {
                              selectedSquare = PieceMoveData(
                                  squareName: squareName,
                                  pieceType:
                                      pieceOnSquare?.type.toUpperCase() ?? 'P',
                                  pieceColor:
                                      pieceOnSquare?.color ?? Color.WHITE);
                              currentLegalSquare = getLegalMoves(game
                                  .squareToIndex(selectedSquare!.squareName));
                              //TODO:implement the setState
                              //setState(() {});
                            },
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                if (currentLegalSquare
                                    .contains(game.squareToIndex(squareName)))
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors
                                          .grey, // You can customize the color
                                    ),
                                  ),
                                Draggable<PieceMoveData>(
                                  feedback: piece,
                                  childWhenDragging: const SizedBox(),
                                  data: PieceMoveData(
                                    squareName: squareName,
                                    pieceType:
                                        pieceOnSquare?.type.toUpperCase() ??
                                            'P',
                                    pieceColor:
                                        pieceOnSquare?.color ?? Color.WHITE,
                                  ),
                                  child: piece,
                                ),
                              ],
                            ),
                          )
                        : InkWell(
                            onTap: () async {
                              final currentSquare =
                                  game.squareToIndex(squareName);
                              if (currentLegalSquare.contains(currentSquare)) {
                                // A way to check if move occurred.
                                Color moveColor = game.turn;

                                if (selectedSquare!.pieceType == "P" &&
                                    ((selectedSquare!.squareName[1] == "7" &&
                                            squareName[1] == "8" &&
                                            selectedSquare!.pieceColor ==
                                                Color.WHITE) ||
                                        (selectedSquare!.squareName[1] == "2" &&
                                            squareName[1] == "1" &&
                                            selectedSquare!.pieceColor ==
                                                Color.BLACK))) {
                                  var val = await _promotionDialog(context);

                                  if (val != null) {
                                    controller.makeMoveWithPromotion(
                                      from: selectedSquare!.squareName,
                                      to: squareName,
                                      pieceToPromoteTo: val,
                                    );
                                  } else {
                                    return;
                                  }
                                } else {
                                  controller.makeMove(
                                    from: selectedSquare!.squareName,
                                    to: squareName,
                                  );
                                }
                                currentLegalSquare.clear();
                                if (game.turn != moveColor) {
                                  onMove?.call();
                                }
                              }
                            },
                            child: Align(
                              alignment: AlignmentDirectional.center,
                              child: currentLegalSquare
                                      .contains(game.squareToIndex(squareName))
                                  ? Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(
                                            0.1), // You can customize the color
                                      ),
                                    )
                                  : null,
                            ),
                          );

                    var dragTarget = DragTarget<PieceMoveData>(
                      builder: (context, list, _) {
                        return draggable;
                      },
                      onWillAcceptWithDetails: (pieceMoveData) {
                        return enableUserMoves ? true : false;
                      },
                      onAcceptWithDetails: (DragTargetDetails<PieceMoveData>
                          pieceMoveData) async {
                        // A way to check if move occurred.
                        Color moveColor = game.turn;

                        if (pieceMoveData.data.pieceType == "P" &&
                            ((pieceMoveData.data.squareName[1] == "7" &&
                                    squareName[1] == "8" &&
                                    pieceMoveData.data.pieceColor ==
                                        Color.WHITE) ||
                                (pieceMoveData.data.squareName[1] == "2" &&
                                    squareName[1] == "1" &&
                                    pieceMoveData.data.pieceColor ==
                                        Color.BLACK))) {
                          var val = await _promotionDialog(context);

                          if (val != null) {
                            controller.makeMoveWithPromotion(
                              from: pieceMoveData.data.squareName,
                              to: squareName,
                              pieceToPromoteTo: val,
                            );
                          } else {
                            return;
                          }
                        } else {
                          controller.makeMove(
                            from: pieceMoveData.data.squareName,
                            to: squareName,
                          );
                        }
                        currentLegalSquare.clear();
                        if (game.turn != moveColor) {
                          onMove?.call();
                        }
                      },
                    );
                    return dragTarget;

                    //return dragTarget;
                  },
                  itemCount: 64,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
              if (arrows.isNotEmpty)
                IgnorePointer(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CustomPaint(
                      painter: _ArrowPainter(arrows, boardOrientation),
                      child: Container(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Image _getBoardImage(BoardColor color) {
    switch (color) {
      case BoardColor.brown:
        return ChessPieceImages.getBrownBoard;

      case BoardColor.green:
        return ChessPieceImages.getGreenBoard;
      case BoardColor.red:
        return ChessPieceImages.getRedBoard;
    }
  }

  Image _getBoardNotation(BoardColor color) {
    switch (color) {
      case BoardColor.brown:
        return ChessPieceImages.getBrownBoardNotation;

      case BoardColor.green:
        return ChessPieceImages.getGreenBoardNotation;
      case BoardColor.red:
        return ChessPieceImages.getRedBoardNotation;
    }
  }

  /// Show dialog when pawn reaches last square
  Future<String?> _promotionDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose promotion'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                child: ChessPieceImages.whiteQueen,
                onTap: () {
                  Navigator.of(context).pop("q");
                },
              ),
              InkWell(
                child: ChessPieceImages.whiteRook,
                onTap: () {
                  Navigator.of(context).pop("r");
                },
              ),
              InkWell(
                child: ChessPieceImages.whiteBishop,
                onTap: () {
                  Navigator.of(context).pop("b");
                },
              ),
              InkWell(
                child: ChessPieceImages.whiteKnight,
                onTap: () {
                  Navigator.of(context).pop("n");
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {
      return value;
    });
  }
}

class BoardPiece extends StatelessWidget {
  final String squareName;
  final Chess game;

  const BoardPiece({
    super.key,
    required this.squareName,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    late Widget imageToDisplay;
    var square = game.get(squareName);

    if (game.get(squareName) == null) {
      return Container();
    }

    String piece = (square?.color == Color.WHITE ? 'W' : 'B') +
        (square?.type.toUpperCase() ?? 'P');

    switch (piece) {
      case "WP":
        imageToDisplay = ChessPieceImages.whitePawn;
        break;
      case "WR":
        imageToDisplay = ChessPieceImages.whiteRook;
        break;
      case "WN":
        imageToDisplay = ChessPieceImages.whiteKnight;
        break;
      case "WB":
        imageToDisplay = ChessPieceImages.whiteBishop;
        break;
      case "WQ":
        imageToDisplay = ChessPieceImages.whiteQueen;
        break;
      case "WK":
        imageToDisplay = ChessPieceImages.whiteKing;
        break;
      case "BP":
        imageToDisplay = ChessPieceImages.blackPawn;
        break;
      case "BR":
        imageToDisplay = ChessPieceImages.blackRook;
        break;
      case "BN":
        imageToDisplay = ChessPieceImages.blackKnight;
        break;
      case "BB":
        imageToDisplay = ChessPieceImages.blackBishop;
        break;
      case "BQ":
        imageToDisplay = ChessPieceImages.blackQueen;
        break;
      case "BK":
        imageToDisplay = ChessPieceImages.blackKing;
        break;
      default:
        imageToDisplay = ChessPieceImages.whitePawn;
    }

    return imageToDisplay;
  }
}

class PieceMoveData {
  final String squareName;
  final String pieceType;
  final Color pieceColor;

  PieceMoveData({
    required this.squareName,
    required this.pieceType,
    required this.pieceColor,
  });
}

class _ArrowPainter extends CustomPainter {
  List<BoardArrow> arrows;
  PlayerColor boardOrientation;

  _ArrowPainter(this.arrows, this.boardOrientation);

  @override
  void paint(Canvas canvas, Size size) {
    var blockSize = size.width / 8;
    var halfBlockSize = size.width / 16;

    for (var arrow in arrows) {
      var startFile = files.indexOf(arrow.from[0]);
      var startRank = int.parse(arrow.from[1]) - 1;
      var endFile = files.indexOf(arrow.to[0]);
      var endRank = int.parse(arrow.to[1]) - 1;

      int effectiveRowStart = 0;
      int effectiveColumnStart = 0;
      int effectiveRowEnd = 0;
      int effectiveColumnEnd = 0;

      if (boardOrientation == PlayerColor.black) {
        effectiveColumnStart = 7 - startFile;
        effectiveColumnEnd = 7 - endFile;
        effectiveRowStart = startRank;
        effectiveRowEnd = endRank;
      } else {
        effectiveColumnStart = startFile;
        effectiveColumnEnd = endFile;
        effectiveRowStart = 7 - startRank;
        effectiveRowEnd = 7 - endRank;
      }

      var startOffset = Offset(
          ((effectiveColumnStart + 1) * blockSize) - halfBlockSize,
          ((effectiveRowStart + 1) * blockSize) - halfBlockSize);
      var endOffset = Offset(
          ((effectiveColumnEnd + 1) * blockSize) - halfBlockSize,
          ((effectiveRowEnd + 1) * blockSize) - halfBlockSize);

      var yDist = 0.8 * (endOffset.dy - startOffset.dy);
      var xDist = 0.8 * (endOffset.dx - startOffset.dx);

      var paint = Paint()
        ..strokeWidth = halfBlockSize * 0.8
        ..color = arrow.color;

      canvas.drawLine(startOffset,
          Offset(startOffset.dx + xDist, startOffset.dy + yDist), paint);

      var slope =
          (endOffset.dy - startOffset.dy) / (endOffset.dx - startOffset.dx);

      var newLineSlope = -1 / slope;

      var points = _getNewPoints(
          Offset(startOffset.dx + xDist, startOffset.dy + yDist),
          newLineSlope,
          halfBlockSize);
      var newPoint1 = points[0];
      var newPoint2 = points[1];

      var path = Path();

      path.moveTo(endOffset.dx, endOffset.dy);
      path.lineTo(newPoint1.dx, newPoint1.dy);
      path.lineTo(newPoint2.dx, newPoint2.dy);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  List<Offset> _getNewPoints(Offset start, double slope, double length) {
    if (slope == double.infinity || slope == double.negativeInfinity) {
      return [
        Offset(start.dx, start.dy + length),
        Offset(start.dx, start.dy - length)
      ];
    }

    return [
      Offset(start.dx + (length / sqrt(1 + (slope * slope))),
          start.dy + ((length * slope) / sqrt(1 + (slope * slope)))),
      Offset(start.dx - (length / sqrt(1 + (slope * slope))),
          start.dy - ((length * slope) / sqrt(1 + (slope * slope)))),
    ];
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return arrows != oldDelegate.arrows;
  }
}
