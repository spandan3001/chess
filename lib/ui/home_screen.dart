import 'package:chess/features/chess_board_controller.dart';
import 'package:chess/ui/board.dart';
import 'package:chess/features/chess.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/home/home_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeBloc = HomeBloc();
  ChessBoardController controller = ChessBoardController();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      bloc: homeBloc,
      buildWhen: (previous,current){

        return true;

      },
      listenWhen: (previous,current){

        return true;

      },
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("CHESS GAME"),
            centerTitle: true,

          ),
          body: ChessBoard(controller:controller ),
        );
      },
    );
  }
}
