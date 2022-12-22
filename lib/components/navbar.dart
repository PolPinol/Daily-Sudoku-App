import 'package:flutter/material.dart';
import 'package:sudoku_app/game.dart';
import 'package:sudoku_app/ranking.dart';
import 'package:sudoku_app/stats.dart';

class NavBar extends StatefulWidget {
  final Function() funCallback;

  NavBar({super.key, required this.funCallback});

  @override
  State<NavBar> createState() => _NavBarState(funCallback: funCallback);
}

class _NavBarState extends State<NavBar> {
  final Function() funCallback;

  _NavBarState({required this.funCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: () {
              //gamePage = 1;
              funCallback();
            },
            child: const Text('Sign-out'),
          ),
          ElevatedButton(
            onPressed: () {
              //widget.page = 1;
              funCallback();
            },
            child: const Text('Today'),
          ),
          ElevatedButton(
            onPressed: () {
              //widget.page = 2;
              funCallback();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }
}
