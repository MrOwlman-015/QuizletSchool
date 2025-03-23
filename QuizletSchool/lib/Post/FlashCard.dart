import 'dart:io';

import 'package:csv/csv.dart';
import 'package:curved_bottom_navigation/API/user.dart';
import 'package:curved_bottom_navigation/API/word.dart';
import 'package:curved_bottom_navigation/Class/LearningProcess.dart';
import 'package:curved_bottom_navigation/Class/Topic.dart';
import 'package:curved_bottom_navigation/Post/AddTopicScreen.dart';
import 'package:curved_bottom_navigation/Post/Preview.dart';
import 'package:curved_bottom_navigation/main.dart';
import 'package:external_path/external_path.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../Class/Word.dart';

class FlashCard extends StatefulWidget {
  FlashCard({super.key, required this.topic, required this.isPushed});
  Topic topic;
  bool isPushed = false;

  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard> {
  FlutterTts tts = FlutterTts();
  Icon unlike = Icon(Icons.star_border);
  Icon like = Icon(Icons.star);
  Icon mark = Icon(Icons.bookmark);
  Icon unmark = Icon(Icons.bookmark_border);
  bool marked = false;

  late LearningProcess learningProcess;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      future: getWordsByTopic(widget.topic.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          const Text(
            "Error in loading words",
            style: TextStyle(
              color: Colors.white,
            ),
          );
        }

        if (snapshot.hasData) {
          List<Word> listWord = [];
          if (snapshot.data != null) {
            listWord = snapshot.data!;
            marked = context
                .read<MyStore>()
                .user
                .favoriteTopics
                .contains(widget.topic.id);
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              centerTitle: true,
              title: Text(widget.topic.name),
              titleTextStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              leading: widget.isPushed
                  ? IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : null,
              actions: [
                IconButton(
                  icon: Icon(Icons.download),
                  color: Colors.yellow,
                  onPressed: () {
                    setState(() {
                      _exportCsv(listWord, widget.topic.name);
                    });
                  },
                ),
                (context.read<MyStore>().user.id != widget.topic.idMaster)
                    ? IconButton(
                        //Luu topic
                        icon: marked ? mark : unmark,
                        color: Colors.yellow,
                        onPressed: () async {
                          setState(() {
                            if (marked) {
                              context
                                  .read<MyStore>()
                                  .user
                                  .favoriteTopics
                                  .remove(widget.topic.id);

                              updateUser(context.read<MyStore>().user).then(
                                  (value) => ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Remove topic from favorite list"))));
                            } else {
                              context
                                  .read<MyStore>()
                                  .user
                                  .favoriteTopics
                                  .add(widget.topic.id);

                              updateUser(context.read<MyStore>().user).then(
                                  (value) => ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Add topic to favorite list"))));
                            }
                            marked = !marked;
                          });
                        },
                      )
                    : IconButton(
                        onPressed: () async {
                          Topic changedTopic = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTopicScreen(
                                importCsv: false,
                                edit: true,
                                topic: widget.topic,
                              ),
                            ),
                          );

                          setState(() {
                            widget.topic = changedTopic;
                          });
                        },
                        icon: Icon(Icons.edit),
                        color: Colors.yellow,
                      ),
              ],
            ),
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    color: Colors.black,
                    alignment: Alignment(-1, 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "@" + widget.topic.authorName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.topic.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PageView.builder(
                  itemCount: listWord.length,
                  itemBuilder: (context, index) {
                    bool liked = context
                        .read<MyStore>()
                        .user
                        .favoriteWords
                        .contains(listWord[index].id);
                    return Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            //luu word
                            icon: liked ? like : unlike,
                            color: Colors.yellow,
                            onPressed: () async {
                              setState(() {
                                if (liked) {
                                  context
                                      .read<MyStore>()
                                      .user
                                      .favoriteWords
                                      .remove(listWord[index].id);

                                  updateUser(context.read<MyStore>().user).then(
                                      (value) => ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Remove word from favorite list"))));
                                } else {
                                  context
                                      .read<MyStore>()
                                      .user
                                      .favoriteWords
                                      .add(listWord[index].id);

                                  updateUser(context.read<MyStore>().user).then(
                                      (value) => ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Add word to favorite list"))));
                                }
                                liked = !liked;
                              });
                            },
                          ),
                          FlipCard(
                            onFlipDone: (isFront) async {
                              // String wordID = listWord[index].id;
                              // if (!learningProcess.learningWords.contains(wordID)) {
                              //   learningProcess.learningWords.add(wordID);
                              // }

                              // if (learningProcess.notLearnWords.contains(wordID)) {
                              //   learningProcess.notLearnWords
                              //       .remove(wordID);
                              // }
                              // await updateLearningProcess(learningProcess);
                              if (widget.topic.idMaster ==
                                  context.read<MyStore>().user.id) {
                                Word word = listWord[index];
                                if (word.status == "not learned") {
                                  word.status = "learning";
                                  await updateWord(word);
                                }
                              }
                            },
                            front: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.3,
                              color: Colors.green.withOpacity(0.4),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.volume_up),
                                    iconSize: 30,
                                    color: Colors.white,
                                    onPressed: () {
                                      tts.setLanguage('en-US');
                                      _speak(listWord[index].english);
                                    },
                                  ),
                                  Text(
                                    listWord[index].english,
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            back: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.3,
                              color: Colors.green.withOpacity(0.4),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.volume_up),
                                    iconSize: 30,
                                    color: Colors.white,
                                    onPressed: () {
                                      tts.setLanguage('vi-VN');
                                      _speak(listWord[index].vietnamese);
                                    },
                                  ),
                                  Text(
                                    listWord[index].vietnamese,
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
                        builder: (context) => Preview(
                              topic: widget.topic,
                              isPushed: true,
                            )),
                  );
                },
                child: Container(
                  color: Colors.black,
                  child: const Center(
                    child: Text(
                      'Nhấn vào để chuyển sang phần kiểm tra',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _speak(String text) async {
    await tts.speak(text);
  }

  void _stop() async {
    await tts.stop();
  }

  Future<void> _exportCsv(List<Word> listWord, String nameTopic) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    List<dynamic> associateList = [];
    for (Word wordModel in listWord) {
      associateList
          .add({'Word': wordModel.english, "Definition": wordModel.vietnamese});
    }

    List<List<dynamic>> rows = [];

    List<dynamic> row = [];
    row.add("Word");
    row.add("Definition");
    rows.add(row);
    for (int i = 0; i < associateList.length; i++) {
      List<dynamic> row = [];
      row.add(associateList[i]["Word"]);
      row.add(associateList[i]["Definition"]);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    String dir = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    String file = "$dir";

    File f = File("$file/${nameTopic}.csv");

    f.writeAsString(csv);
  }
}
