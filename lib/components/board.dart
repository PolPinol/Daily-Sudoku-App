import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:developer';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  List<List<int>> sudoku = [
    [1, 0, 3, 4, 5, 6, 7, 8, 0],
    [0, 2, 0, 4, 5, 6, 7, 8, 0],
    [1, 0, 3, 0, 5, 6, 7, 0, 9],
    [1, 2, 3, 4, 5, 6, 0, 8, 9],
    [1, 0, 3, 4, 5, 0, 7, 8, 9],
    [1, 2, 0, 4, 5, 0, 7, 0, 9],
    [1, 0, 3, 4, 5, 0, 0, 8, 9],
    [1, 2, 0, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
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
      log('isSuccess: ${response.statusCode}');
      return reply;
    } catch (exception) {
      throw (exception.toString());
    }
  }

  int selected = -1;

  @override
  void dispose() {
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

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      setState(() {
        _start++;
      });
    });
    log('hola');
    generateSudoku().then((value) => log('data: $value'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Errors: 0/3',
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
                          sudoku[selected ~/ 9][selected % 9] = (index + 1);
                        }
                      });
                    },
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }),
            ),
          )
        ]);
  }
}
