import 'package:curved_bottom_navigation/API/word.dart';
import 'package:curved_bottom_navigation/Class/Topic.dart';
import 'package:curved_bottom_navigation/Post/FlashCard.dart';
import 'package:curved_bottom_navigation/Post/MultipleChoice.dart';
import 'package:flutter/material.dart';

import '../Class/Word.dart';
import 'Spelling.dart';

class Preview extends StatelessWidget {
  Preview({super.key, required this.topic, required this.isPushed});
  final Topic topic;
  bool isPushed = false;
  List<Word> listWord = [];

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(topic.name),
          titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          leading: isPushed
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
        ),
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                alignment: Alignment(-1, 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '@' + topic.authorName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      topic.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: FutureBuilder(
                    future: getWordsByTopic(topic.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text("There are errors in loading words"),
                        );
                      }
                      if (snapshot.hasData) {
                        if (snapshot.data != null &&
                            snapshot.data!.length > 3) {
                          listWord = snapshot.data!;
                          return Stack(
                            children: [
                              RotationTransition(
                                turns: const AlwaysStoppedAnimation(-30 / 360),
                                child: Center(
                                  child: Container(
                                    width: 140,
                                    height: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        border: Border.all(
                                            width: 2, color: Colors.green),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    margin: const EdgeInsets.only(
                                        left: 0, right: 170, bottom: 100),
                                    child: Center(
                                      child: Text(
                                        listWord[2].english,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              RotationTransition(
                                turns: const AlwaysStoppedAnimation(30 / 360),
                                child: Center(
                                  child: Container(
                                    width: 140,
                                    height: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.lime,
                                        border: Border.all(
                                            width: 2, color: Colors.green),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    margin: const EdgeInsets.only(
                                        left: 170, right: 0, bottom: 100),
                                    child: Center(
                                      child: Text(
                                        listWord[1].english,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              RotationTransition(
                                turns: const AlwaysStoppedAnimation(0 / 360),
                                child: Center(
                                  child: Container(
                                    width: 150,
                                    height: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        border: Border.all(
                                            width: 2, color: Colors.green),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    margin: const EdgeInsets.only(
                                        left: 0, right: 0, bottom: 20),
                                    child: Center(
                                      child: Text(
                                        listWord[0].english,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultipleChoice(
                                topic: topic,
                              ),
                            ),
                          );
                        },
                        child: const Text("Multiple Choice"),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                        color: Colors.white)))),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Spelling(
                                  topic: topic,
                                ),
                              ));
                        },
                        child: const Text("Spelling"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        persistentFooterButtons: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FlashCard(
                          topic: topic,
                          isPushed: true,
                        )),
              );
            },
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Nhấn vào để chuyển sang phần học',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
