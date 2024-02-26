import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'board_event.dart';
part 'board_state.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  BoardBloc() : super(BoardInitial()) {
    on<BoardEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
