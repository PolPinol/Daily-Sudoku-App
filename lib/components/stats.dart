import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key, required this.uid});

  final String uid;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _gamesStarted = 0;
  int _gamesWon = 0;
  num _winRate = 0;
  int _bestTime = 0;
  num _averageTime = 0;
  bool _disposed = false;

  _loadStats() async {
    CollectionReference games = FirebaseFirestore.instance.collection('games');
    QuerySnapshot querySnapshot =
        await games.where('uid', isEqualTo: widget.uid).get();
    for (var doc in querySnapshot.docs) {
      _gamesStarted++;
      if (doc['completed']) {
        _gamesWon++;
        if (_bestTime == 0 || doc['time'] < _bestTime) {
          _bestTime = doc['time'];
        }
        _averageTime += doc['time'].toInt();
      }
    }
    if (_gamesStarted > 0) {
      _winRate = (_gamesWon / _gamesStarted * 100).toInt();
    }

    if (_gamesWon > 0) {
      _averageTime = _averageTime ~/ _gamesWon;
    }

    if (!_disposed) {
      setState(() {});
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    super.initState();
    _disposed = false;
    _loadStats();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Games', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(57, 128, 224, 0.19),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.only(left: 16.0, right: 16.0),
                  leading: const Icon(
                    MdiIcons.tableLarge,
                    color: Colors.blue,
                  ),
                  title: const Text('Games started'),
                  trailing: Text('$_gamesStarted'),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(57, 128, 224, 0.19),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.only(left: 16.0, right: 16.0),
                  leading: const Icon(MdiIcons.trophy, color: Colors.blue),
                  title: const Text('Games won'),
                  trailing: Text('$_gamesWon'),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(57, 128, 224, 0.19),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.only(left: 16.0, right: 16.0),
                  leading: const Icon(MdiIcons.flag, color: Colors.blue),
                  title: const Text('Win rate'),
                  trailing: Text('$_winRate%'),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Time', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(57, 128, 224, 0.19),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.only(left: 16.0, right: 16.0),
                  leading: const Icon(MdiIcons.timer, color: Colors.blue),
                  title: const Text('Best time'),
                  trailing: Text(_printDuration(Duration(seconds: _bestTime))),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(57, 128, 224, 0.19),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.only(left: 16.0, right: 16.0),
                  leading: const Icon(MdiIcons.clockPlus, color: Colors.blue),
                  title: const Text('Average time'),
                  trailing: Text(
                      _printDuration(Duration(seconds: _averageTime.toInt()))),
                ),
              ),
            ]),
      ),
    );
  }
}
