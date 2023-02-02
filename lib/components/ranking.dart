import 'package:flutter/material.dart';
import 'package:firebase_admin/firebase_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Rank implements Comparable<Rank> {
  String uid;
  String mail;
  int gamesWon;
  int gamesStarted;
  int bestTime;
  int averageTime;

  Rank(
      {required this.uid,
      required this.mail,
      required this.gamesWon,
      required this.gamesStarted,
      required this.bestTime,
      required this.averageTime});

  @override
  int compareTo(Rank other) {
    if (gamesWon == other.gamesWon) {
      if (bestTime == other.bestTime) {
        return averageTime.compareTo(other.averageTime);
      }
      return bestTime.compareTo(other.bestTime);
    }
    return gamesWon.compareTo(other.gamesWon);
  }
}

// ranking page

class RankingPage extends StatefulWidget {
  const RankingPage({super.key, required this.uid});

  final String uid;

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> with WidgetsBindingObserver {
  final List<Rank> _ranks = [];
  final credential = Credentials.applicationDefault();
  bool _disposed = false;

  loadRanking() async {
    WidgetsBinding.instance.addObserver(this);
    CollectionReference games = FirebaseFirestore.instance.collection('games');
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot qs = await users.get();

    for (var doc in qs.docs) {
      var uid = doc['uid'];
      var mail = doc['mail'];
      var gamesWon = 0;
      var gamesStarted = 0;
      var bestTime = 0;
      num averageTime = 0;

      QuerySnapshot querySnapshot =
          await games.where('uid', isEqualTo: uid).get();
      for (var doc in querySnapshot.docs) {
        gamesStarted++;
        if (doc['completed']) {
          gamesWon++;
          if (bestTime == 0 || doc['time'] < bestTime) {
            bestTime = doc['time'];
          }
          averageTime += doc['time'];
        }
      }

      if (gamesWon > 0) {
        averageTime = averageTime ~/ gamesWon;
      }

      _ranks.add(Rank(
          uid: uid,
          mail: mail,
          gamesWon: gamesWon,
          gamesStarted: gamesStarted,
          bestTime: bestTime,
          averageTime: averageTime.toInt()));
    }

    _ranks.sort((a, b) => b.compareTo(a));
    if (!_disposed) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _disposed = false;
    loadRanking();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16, left: 16, bottom: 16),
              alignment: Alignment.topLeft,
              child: const Text(
                "Top Ranks",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 24,
                ),
              ),
            ),
            ListView.separated(
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.blue),
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _ranks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.only(left: 16.0, right: 16.0),
                    leading: index < 3
                        ? Icon(
                            MdiIcons.trophy,
                            color: index == 0
                                ? Colors.yellow
                                : index == 1
                                    ? Colors.grey
                                    : Colors.brown,
                          )
                        : Text((index + 1).toString()),
                    title: Text(_ranks[index].mail.split('@')[0],
                        style: TextStyle(
                          color: _ranks[index].uid == widget.uid
                              ? Colors.blue
                              : Colors.black,
                          fontSize: 16,
                        )),
                    trailing: Text(_ranks[index].gamesWon.toString()),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
