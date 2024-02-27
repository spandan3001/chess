// ignore_for_file: constant_identifier_names

const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

/// Enum which stores board types
enum BoardColor {
  brown,
  red,
  green,
}

enum PlayerColor {
  white,
  black,
}

enum BoardPieceType { Pawn, Rook, Knight, Bishop, Queen, King }

RegExp squareRegex = RegExp("^[A-H|a-h][1-8]\$");
