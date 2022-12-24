import 'package:flutter/material.dart';
import 'package:sudoku_app/components/board.dart';
import 'package:sudoku_app/components/ranking.dart';
import 'package:sudoku_app/components/stats.dart';

class GamePage extends StatefulWidget {
  GamePage({super.key, required this.uid});

  final String uid;

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
                  const SizedBox(
                    height: 100,
                    width: 100,
                    child: StatsPage(),
                  ),
                ],
                Visibility(
                  child: Board(uid: widget.uid),
                  visible: pageGame == 1,
                  maintainState: true,
                ),
                if (pageGame == 2) ...[
                  const SizedBox(
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
                        child: const Text(
                          '\u{1F31F}',
                          style: TextStyle(fontSize: 30),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: pageGame == 0
                              ? Color.fromARGB(255, 129, 190, 241)
                              : Colors.transparent,
                          onPrimary: Colors.black,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showBoardPage();
                        },
                        child: const Text('\u{1F5D3}',
                            style: TextStyle(fontSize: 30)),
                        style: ElevatedButton.styleFrom(
                          primary: pageGame == 1
                              ? Color.fromARGB(255, 129, 190, 241)
                              : Colors.transparent,
                          onPrimary: Colors.black,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showRankingPage();
                        },
                        child: const Text(
                          '\u{1F3C6}',
                          style: TextStyle(fontSize: 30),
                        ),
                        // width of the button fixed to the text
                        style: ElevatedButton.styleFrom(
                          primary: pageGame == 2
                              ? Color.fromARGB(255, 129, 190, 241)
                              : Colors.transparent,
                          onPrimary: Colors.black,
                          shadowColor: Colors.transparent,
                        ),
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
