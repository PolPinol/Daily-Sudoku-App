import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class Board extends StatefulWidget {
  final String uid;

  const Board({super.key, required this.uid});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  late Timer _timer;
  int _start = 0;

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  initGameOfDay() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

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
              'errors': 0
            })
            .then((value) => print("Game Added"))
            .catchError((error) => print("Failed to add game: $error"));
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
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    WidgetsBinding.instance.addObserver(this);

    CollectionReference games = FirebaseFirestore.instance.collection('games');

    Future<void> recoverDraftGame() {
      return games
          .where('uid', isEqualTo: widget.uid)
          .where('date',
              isEqualTo:
                  "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}")
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          _start = doc['time'].toInt();
          errors = doc['errors'].toInt();

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

          _timer =
              Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
            setState(() {
              _start++;
            });
          });

          setState(() {});
        }
        if (querySnapshot.docs.isEmpty) {
          initGameOfDay();
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
          });
        }
      });
    }

    updateGame();
  }

  @override
  void initState() {
    super.initState();
    recoverDraftGameOrInitGame();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // nothing
        break;
      case AppLifecycleState.paused:
        saveGame();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                'Errors: ${errors}/3',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(
                width: 67,
                child: Text(
                  _printDuration(Duration(seconds: _start)),
                  style: TextStyle(fontSize: 15),
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
                    top: BorderSide(
                      width: 0.5,
                      color: Color.fromARGB(255, 135, 159, 175),
                    ),
                    left: BorderSide(
                      width: 0.5,
                      color: Color.fromARGB(255, 135, 159, 175),
                    ),
                    right: BorderSide(
                      width: (index + 1) % 3 == 0 && (index + 1) % 9 != 0
                          ? 1.75
                          : 0.5,
                      color: Color.fromARGB(255, 135, 159, 175),
                    ),
                    bottom: BorderSide(
                      width: (index > 17 && index < 27) ||
                              (index > 44 && index < 54)
                          ? 1.75
                          : 0.5,
                      color: Color.fromARGB(255, 135, 159, 175),
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
                              ? Color.fromARGB(71, 0, 199, 254)
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
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(9, (index) {
                return Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        if (selected != -1 &&
                            sudoku[selected ~/ 9][selected % 9] == 0) {
                          if ((index + 1) !=
                              solutions[selected ~/ 9][selected % 9]) {
                            errors++;
                          } else {
                            sudoku[selected ~/ 9][selected % 9] = (index + 1);
                          }
                        }
                      });
                    },
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  ),
                );
              }),
            ),
          )
        ]);
  }
}
