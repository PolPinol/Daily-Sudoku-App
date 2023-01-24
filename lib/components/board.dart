import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import 'package:cool_alert/cool_alert.dart';

// This class is required to notify a child that the logout button was pressed
class FloatingActionButtonNotifier extends ChangeNotifier {
  void onFloationActionButtonPressed() {
    notifyListeners();
  }
}

class Board extends StatefulWidget {
  final String uid;
  final FloatingActionButtonNotifier fabNotifier;
  @override
  // ignore: overridden_fields
  final PageStorageKey key = const PageStorageKey("BoardPage");

  const Board({required Key key, required this.uid, required this.fabNotifier})
      : super(key: key);

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late ConfettiController _controllerCenter;
  bool _isSolved = false;
  bool _isLocked = false;

  @override
  bool get wantKeepAlive => true;

  //
  List<List<int>> sudoku = [
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0)
  ];

  List<List<int>> solutions = [
    List<int>.filled(9, 1),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0),
    List<int>.filled(9, 0)
  ];

  Future<String> generateSudoku() async {
    HttpClient client = HttpClient();
    try {
      Uri uri = Uri.https('sudoku-api.vercel.app', '/api/dosuku', {});
      HttpClientRequest request = await client.postUrl(uri);
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      client.close();
      return reply;
    } catch (exception) {
      return 'Failed';
    }
  }

  int selected = -1;
  int errors = 0;

  @override
  void dispose() {
    widget.fabNotifier.removeListener(saveGame);
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controllerCenter.dispose();
    super.dispose();
  }

  Timer? _timer;
  int _start = 0;

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  initGameOfDay() {
    generateSudoku().then((result) {
      final parsed = jsonDecode(result);
      final dataVal = parsed['newboard']['grids'][0]['value'];
      final dataSol = parsed['newboard']['grids'][0]['solution'];

      List<List<int>> tempSudoku = [];
      List<dynamic> temp = json.decode(dataVal.toString());
      temp.forEach((element) {
        List<dynamic> temp2 = json.decode(element.toString());
        tempSudoku.add(temp2.map((e) => e as int).toList());
      });
      sudoku = tempSudoku;

      List<List<int>> tempSolutions = [];
      List<dynamic> temp3 = json.decode(dataSol.toString());
      temp3.forEach((element) {
        List<dynamic> temp4 = json.decode(element.toString());
        tempSolutions.add(temp4.map((e) => e as int).toList());
      });
      solutions = tempSolutions;

      log(dataSol.toString());

      CollectionReference games =
          FirebaseFirestore.instance.collection('games');

      Future<void> addGame() {
        return games
            .add({
              'dataVal': dataVal.toString(),
              'dataSol': dataSol.toString(),
              'uid': widget.uid,
              'date':
                  "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
              'time': 0,
              'errors': 0,
              'completed': false,
            })
            .then((value) => log("Game Added"))
            .catchError((error) => log("Failed to add game: $error"));
      }

      addGame();

      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
        setState(() {
          _start++;
        });
      });

      setState(() {});
    });
  }

  recoverDraftGameOrInitGame() {
    WidgetsBinding.instance.addObserver(this);

    CollectionReference games = FirebaseFirestore.instance.collection('games');

    Future<void> recoverDraftGame() {
      log(widget.uid);
      return games
          .where('uid', isEqualTo: widget.uid)
          .where('date',
              isEqualTo:
                  "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}")
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          initGameOfDay();
        } else {
          log(querySnapshot.docs.length.toString());
          for (var doc in querySnapshot.docs) {
            _start = doc['time'].toInt();
            errors = doc['errors'].toInt();
            _isSolved = doc['completed'];
            _isLocked = errors >= 3 || _isSolved;

            final dataVal = doc['dataVal'];
            final dataSol = doc['dataSol'];

            List<List<int>> tempSudoku = [];
            List<dynamic> temp = json.decode(dataVal.toString());
            temp.forEach((element) {
              List<dynamic> temp2 = json.decode(element.toString());
              tempSudoku.add(temp2.map((e) => e as int).toList());
            });
            sudoku = tempSudoku;

            List<List<int>> tempSolutions = [];
            List<dynamic> temp3 = json.decode(dataSol.toString());
            temp3.forEach((element) {
              List<dynamic> temp4 = json.decode(element.toString());
              tempSolutions.add(temp4.map((e) => e as int).toList());
            });
            solutions = tempSolutions;

            log(dataSol.toString());

            setState(() {});
          }
          if (!_isLocked) {
            _timer =
                Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
              setState(() {
                _start++;
              });
            });
          }
        }
      });
    }

    recoverDraftGame();
  }

  saveGame() {
    CollectionReference games = FirebaseFirestore.instance.collection('games');

    Future<void> updateGame() {
      return games
          .where('uid', isEqualTo: widget.uid)
          .where('date',
              isEqualTo:
                  "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}")
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({
            'dataVal': sudoku.toString(),
            'dataSol': solutions.toString(),
            'date':
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
            'errors': errors,
            'time': _start,
            'completed': _isSolved,
          });
        }
      });
    }

    updateGame();
  }

  bool isSudokuSolved() {
    return sudoku.toString() == solutions.toString();
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (math.pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * math.cos(step),
          halfWidth + externalRadius * math.sin(step));
      path.lineTo(
          halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  void initState() {
    super.initState();
    recoverDraftGameOrInitGame();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));
    widget.fabNotifier.addListener(saveGame);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isLocked) {
      saveGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: [
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Errors: $errors/3',
                  style: const TextStyle(fontSize: 15),
                ),
                SizedBox(
                  width: 67,
                  child: Text(
                    _printDuration(Duration(seconds: _start)),
                    style: const TextStyle(fontSize: 15),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 9,
              children: List.generate(81, (index) {
                return Container(
                  height: 100.0,
                  decoration: BoxDecoration(
                    border: Border(
                      top: const BorderSide(
                        width: 0.5,
                        color: Color.fromARGB(255, 135, 159, 175),
                      ),
                      left: const BorderSide(
                        width: 0.5,
                        color: Color.fromARGB(255, 135, 159, 175),
                      ),
                      right: BorderSide(
                        width: (index + 1) % 3 == 0 && (index + 1) % 9 != 0
                            ? 1.75
                            : 0.5,
                        color: const Color.fromARGB(255, 135, 159, 175),
                      ),
                      bottom: BorderSide(
                        width: (index > 17 && index < 27) ||
                                (index > 44 && index < 54)
                            ? 1.75
                            : 0.5,
                        color: const Color.fromARGB(255, 135, 159, 175),
                      ),
                    ),
                  ),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selected == index ? selected = -1 : selected = index;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            selected == index &&
                                    sudoku[selected ~/ 9][selected % 9] == 0
                                ? (!_isLocked
                                    ? const Color.fromARGB(71, 0, 199, 254)
                                    : const Color.fromARGB(82, 254, 0, 21))
                                : Colors.white),
                      ),
                      child: Text(
                        sudoku[index ~/ 9][index % 9] != 0
                            ? sudoku[index ~/ 9][index % 9].toString()
                            : '',
                        style: const TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(
              height: 50,
            ),
            // numbers in a row to select text button with number and onpressed

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(9, (index) {
                return Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        if (_isLocked) return;
                        if (selected != -1 &&
                            sudoku[selected ~/ 9][selected % 9] == 0) {
                          if ((index + 1) !=
                              solutions[selected ~/ 9][selected % 9]) {
                            errors++;
                            if (errors >= 3) {
                              saveGame();
                              _timer?.cancel();
                              _isLocked = errors >= 3;
                              CoolAlert.show(
                                context: context,
                                type: CoolAlertType.error,
                                title: 'Game Over!',
                                text: 'No more attemps left!',
                                autoCloseDuration: const Duration(seconds: 4),
                              );
                            }
                          } else {
                            sudoku[selected ~/ 9][selected % 9] = (index + 1);
                            // If all the cells are filled, then check if the solution is correct
                            if (isSudokuSolved()) {
                              _isLocked = true;
                              _isSolved = true;
                              saveGame();
                              _timer?.cancel();
                              _controllerCenter.play();
                              CoolAlert.show(
                                context: context,
                                type: CoolAlertType.success,
                                title: 'Congratulations!',
                                text: 'Daily Sudoku Completed!',
                                onConfirmBtnTap: () => null,
                                autoCloseDuration: const Duration(seconds: 4),
                              );
                            }
                          }
                        }
                      });
                    },
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  ),
                );
              }),
            ),
          ]),
      Align(
        alignment: Alignment.center,
        child: ConfettiWidget(
          confettiController: _controllerCenter,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple
          ], // manually specify the colors to be used
          createParticlePath: drawStar, // define a custom shape/path.
        ),
      ),
    ]);
  }
}
