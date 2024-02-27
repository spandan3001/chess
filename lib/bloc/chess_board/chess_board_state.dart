part of 'chess_board_cubit.dart';

@immutable
abstract class ChessBoardState {}

class ChessBoardInitial extends ChessBoardState {
  final Chess chess;

  ChessBoardInitial(this.chess);

}
