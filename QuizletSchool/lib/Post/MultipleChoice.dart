import 'dart:async';
import 'dart:math';

import 'package:curved_bottom_navigation/API/result.dart';
import 'package:curved_bottom_navigation/API/user.dart';
import 'package:curved_bottom_navigation/API/word.dart';
import 'package:curved_bottom_navigation/Class/Result.dart';
import 'package:curved_bottom_navigation/Class/Topic.dart';
import 'package:curved_bottom_navigation/Class/User.dart';
import 'package:curved_bottom_navigation/main.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../Class/Word.dart';

class MultipleChoice extends StatefulWidget {
  const MultipleChoice({super.key, required this.topic});
  final Topic topic;
  @override
  State<StatefulWidget> createState() => MultipleChoiceState(topic);
}

class MultipleChoiceState extends State<MultipleChoice>
    with TickerProviderStateMixin {
  late AnimationController controller;
  MultipleChoiceState(this.topic);
  final Topic topic;
  int timeLeft = 5;
  int clock = 0;
  bool startScreen = true;
  bool result = false;
  bool questEng = true;
  int indexWord = 0;
  int curQuest = -1;
  int score = 0;
  List<Word> listWord = [];
  List<String> quest = [];
  List<String> answer = [];
  List<String> option = [];
  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: false);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _startCountDown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        _startClock();
      }
    });
  }

  void _startClock() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!result) {
        setState(() {
          clock++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // generateQuest();
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitWidth,
          image: NetworkImage(
            topic.imageUrl != null ? topic.imageUrl! : "",
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: Text(
            topic.name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _changeBody(),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.height * 0.05,
          child: FlipCard(
            onFlip: () {
              setState(() {
                questEng = !questEng;
                quest.clear();
                answer.clear();
                curQuest--;
                generateQuest();
              });
            },
            front: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 1, color: Colors.white))),
                child: const Text(
                  "English",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )),
            back: Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 1, color: Colors.white))),
              child: const Text(
                "VietNamese",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
        const Center(
          child: Text(
            "Ready",
            style: TextStyle(color: Colors.white, fontSize: 50),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        FutureBuilder(
          future: getWordsByTopic(topic.id),
          builder: (context, snapshot) {
            bool isEnable = false;
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                listWord = snapshot.data!;
                if (listWord.isNotEmpty) {
                  isEnable = true;
                }
              }
            }

            return ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.transparent),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              onPressed: isEnable
                  ? () {
                      setState(
                        () {
                          startScreen = false;
                          generateQuest();
                          _startCountDown();
                        },
                      );
                    }
                  : null,
              child: const Text(
                "Go",
                style: TextStyle(fontSize: 30),
              ),
            );
          },
        ),
        FutureBuilder(
          future: getResultByTopicIDAndType(topic.id, "multiple_choice"),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error in loading reault: ${snapshot.error}",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                List<Result> results = snapshot.data!;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.only(top: 30, left: 20, right: 20),
                      child: (results.length > 1)
                          ? FutureBuilder(
                              future: getUserByID(results[1].idUser),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Container(
                                    width: 90,
                                    child: Center(
                                      child: Text(
                                        "Error in loading user: \n${snapshot.error}",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }

                                if (snapshot.hasData) {
                                  Users user2ND = snapshot.data!;

                                  return Column(
                                    children: [
                                      Container(
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage((user2ND
                                                          .avatarUrl !=
                                                      null &&
                                                  user2ND.avatarUrl!.isNotEmpty)
                                              ? user2ND.avatarUrl!
                                              : "https://www.shutterstock.com/image-vector/silver-medal-vector-2nd-place-260nw-695553751.jpg"),
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                      Container(
                                        width: 65,
                                        child: Text(
                                          user2ND.name,
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 20,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      Container(
                                        height: 90,
                                        width: 50,
                                        color: Colors.green,
                                      ),
                                      Container(
                                          child: Text(
                                        "${results[1].time}",
                                        style: TextStyle(
                                            color: Colors.green, fontSize: 20),
                                      )),
                                    ],
                                  );
                                }

                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            )
                          : null,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: (results.isNotEmpty)
                          ? FutureBuilder(
                              future: getUserByID(results[0].idUser),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Container(
                                    width: 90,
                                    child: Center(
                                      child: Text(
                                        "Error in loading user: \n${snapshot.error}",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }

                                if (snapshot.hasData) {
                                  Users user1ST = snapshot.data!;

                                  return Column(
                                    children: [
                                      Container(
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage((user1ST
                                                          .avatarUrl !=
                                                      null &&
                                                  user1ST.avatarUrl!.isNotEmpty)
                                              ? user1ST.avatarUrl!
                                              : "https://www.shutterstock.com/image-vector/first-place-gold-rosette-vector-260nw-234528031.jpg"),
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                      Container(
                                        width: 65,
                                        child: Text(
                                          user1ST.name,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 20,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      Container(
                                        height: 120,
                                        width: 50,
                                        color: Colors.red,
                                      ),
                                      Container(
                                          child: Text(
                                        "${results[0].time}",
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 20),
                                      )),
                                    ],
                                  );
                                }

                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            )
                          : null,
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 50, left: 20, right: 20),
                      child: (results.length > 2)
                          ? FutureBuilder(
                              future: getUserByID(results[2].idUser),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Container(
                                    width: 90,
                                    child: Center(
                                      child: Text(
                                        "Error in loading user: \n${snapshot.error}",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }

                                if (snapshot.hasData) {
                                  Users user3RD = snapshot.data!;

                                  return Column(
                                    children: [
                                      Container(
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage((user3RD
                                                          .avatarUrl !=
                                                      null &&
                                                  user3RD.avatarUrl!.isNotEmpty)
                                              ? user3RD.avatarUrl!
                                              : "https://www.shutterstock.com/image-vector/bronze-medal-red-ribbon-3rd-260nw-1708917886.jpg"),
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                      Container(
                                        width: 65,
                                        child: Text(
                                          user3RD.name,
                                          style: TextStyle(
                                              color: Colors.yellow,
                                              fontSize: 20,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      Container(
                                        height: 70,
                                        width: 50,
                                        color: Colors.yellow,
                                      ),
                                      Container(
                                          child: Text(
                                        "${results[2].time}",
                                        style: TextStyle(
                                            color: Colors.yellow, fontSize: 20),
                                      )),
                                    ],
                                  );
                                }

                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            )
                          : null,
                    )
                  ],
                );
              }
            }
            return const CircularProgressIndicator();
          },
        ),
      ],
    );
  }

  Widget _buildCountDown() {
    return Center(
      child: Text(
        timeLeft.toString(),
        style: const TextStyle(fontSize: 60, color: Colors.white),
      ),
    );
  }

  Widget _changeBody() {
    if (startScreen) {
      return _buildStartScreen();
    } else {
      if (timeLeft != 0) {
        return _buildCountDown();
      }
      if (!result) {
        return _bodyQuest();
      }
      return _resultScreen();
    }
  }

  Widget _bodyQuest() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 0.3,
          child: Card(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                quest[indexWord],
                style: TextStyle(color: Colors.black, fontSize: 30),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                alignment: Alignment.center,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.6),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                score.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            Container(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.6),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                              value: controller.value)),
                    ),
                    Text(
                      clock.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 50),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.48,
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          color: Colors.white)))),
                      onPressed: () {
                        calScore(option[0]);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          option[0],
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.04,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.48,
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          color: Colors.white)))),
                      onPressed: () {
                        calScore(option[1]);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          option[1],
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.48,
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          color: Colors.white)))),
                      onPressed: () {
                        calScore(option[2]);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          option[2],
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.04,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.48,
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          color: Colors.white)))),
                      onPressed: () {
                        calScore(option[3]);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          option[3],
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _resultScreen() {
    return Container(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 0.2,
          child: Text(
            "Congrats\n${context.read<MyStore>().user.name}",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 0.1,
          child: const Text(
            "Results:",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        Row(
          children: [
            Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                                value: (score / listWord.length).toDouble())),
                      ),
                      Text(
                        (score * 100 / listWord.length).toString() + "%",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: const Text(
                    "Accuracy",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.access_time_outlined,
                          size: 100,
                          color: Colors.grey.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        clock.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: const Text(
                    "Time",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
        ElevatedButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.transparent),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.white)))),
            onPressed: () {
              setState(() {
                timeLeft = 5;
                clock = 0;
                startScreen = true;
                result = false;
                questEng = true;
                indexWord = 0;
                curQuest = -1;
                score = 0;
                quest.clear();
                answer.clear();
              });
            },
            child: const Text(
              "Try again",
              style: TextStyle(fontSize: 30),
            )),
      ]),
    );
  }

  void generateQuest() {
    if (listWord.length != quest.length) {
      listWord.shuffle();
      if (questEng) {
        for (Word s in listWord) {
          quest.add(s.english);
          answer.add(s.vietnamese);
        }
      } else {
        for (Word s in listWord) {
          quest.add(s.vietnamese);
          answer.add(s.english);
        }
      }
    }
    generateOp();
  }

  void generateOp() {
    if (curQuest != indexWord) {
      option.clear();
      option.add(answer[indexWord]);
      int indexOp = 0;
      var ran = Random();
      while (option.length < 4) {
        indexOp = ran.nextInt(answer.length);
        if (!option.contains(answer[indexOp])) {
          option.add(answer[indexOp]);
        }
      }
      option.shuffle();
      curQuest = indexWord;
    }
  }

  void calScore(String choice) async {
    if (choice == answer[indexWord]) {
      Word word = listWord
          .where((element) =>
              element.english == choice || element.vietnamese == choice)
          .first;

      if (topic.idMaster == context.read<MyStore>().user.id) {
        word.numberOfAnwserCorrect++;
        if (word.numberOfAnwserCorrect > 10) {
          word.status = "mastered";
        }
        await updateWord(word);
      }
      score++;
    }
    if (indexWord < listWord.length - 1) {
      indexWord++;
      generateOp();
    } else {
      result = true;
      if (score == listWord.length) {
        await addResult(Result(
            id: const Uuid().v4(),
            idTopic: topic.id,
            idUser: context.read<MyStore>().user.id,
            time: clock,
            score: score,
            type: "multiple_choice",
            completedAt: DateTime.now()));
      }
    }
  }
}
