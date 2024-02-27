import 'package:chess/features/chess.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'chess_board_state.dart';

class ChessBoardCubit extends Cubit<ChessBoardInitial> {
  ChessBoardCubit(Chess chess
      ) : super(ChessBoardInitial(chess));
}
