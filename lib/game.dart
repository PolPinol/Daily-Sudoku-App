import 'package:flutter/material.dart';
import 'package:sudoku_app/components/board.dart';
import 'package:sudoku_app/components/ranking.dart';
import 'package:sudoku_app/components/stats.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_app/signin.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.uid});

  final String uid;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _pageGame = 1;
  final FloatingActionButtonNotifier _fabNotifier =
      FloatingActionButtonNotifier();
  final PageController _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 50.0,
                bottom: 50.0,
              ),
              child: PageView.builder(
                itemCount: 3,
                controller: _pageController,
                onPageChanged: (value) => setState(() => _pageGame = value),
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return StatsPage(uid: widget.uid);
                    case 1:
                      return Board(
                          key: const PageStorageKey("BoardPage"),
                          uid: widget.uid,
                          fabNotifier: _fabNotifier);
                    case 2:
                      return RankingPage(uid: widget.uid);
                    default:
                      return Container();
                  }
                },
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                _fabNotifier.onFloationActionButtonPressed();
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString('uid', '');
                });
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.logout),
            ),
          ),
          bottomNavigationBar: DotNavigationBar(
            currentIndex: _pageGame,
            onTap: (index) {
              setState(() {
                _pageGame = index;
              });
              _pageController.jumpToPage(index);
            },
            items: [
              DotNavigationBarItem(
                icon: const Icon(Icons.bar_chart),
                selectedColor: Colors.blue,
              ),
              DotNavigationBarItem(
                icon: const Icon(Icons.grid_view),
                selectedColor: Colors.blue,
              ),
              DotNavigationBarItem(
                icon: const Icon(Icons.leaderboard),
                selectedColor: Colors.blue,
              ),
            ],
          )),
    );
  }
}
