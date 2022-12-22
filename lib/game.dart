import 'package:flutter/material.dart';
import 'package:sudoku_app/components/board.dart';
import 'package:sudoku_app/components/navbar.dart';
import 'package:sudoku_app/ranking.dart';
import 'package:sudoku_app/stats.dart';

class GamePage extends StatefulWidget {
  GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int pageGame = 1;

  void showStatsPage() {
    setState(() {
      pageGame = 0;
    });
  }

  void showBoardPage() {
    setState(() {
      pageGame = 1;
    });
  }

  void showRankingPage() {
    setState(() {
      pageGame = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 50.0,
            bottom: 50.0,
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (pageGame == 0) ...[
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: StatsPage(),
                  ),
                ],
                if (pageGame == 1) ...[
                  Board(),
                ],
                if (pageGame == 2) ...[
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: RankingPage(),
                  ),
                ],
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showStatsPage();
                        },
                        child: const Text('Stats'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showBoardPage();
                        },
                        child: const Text('Today'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showRankingPage();
                        },
                        child: const Text('\u00a9'),
                      ),
                    ],
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
