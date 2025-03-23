import 'dart:async';

import 'package:curved_bottom_navigation/API/topic.dart';
import 'package:flutter/material.dart';

import '../Class/Topic.dart';
import '../Post/Preview.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => ChallengeScreenState();
}

class ChallengeScreenState extends State<ChallengeScreen> {
  final _controller = PageController();
  late StreamController<List<Topic>> _streamController;
  //Load topic

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _streamController = StreamController<List<Topic>>();
    _loadTopic();
  }

  void _loadTopic() async {
    getTopics().then((value) => _streamController.sink.add(value));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error in load topics"),
            );
          }

          if (snapshot.hasData) {
            List<Topic> listTopic = [];
            if (snapshot.data != null) {
              listTopic = snapshot.data!;
            }

            return PageView.builder(
              itemCount: listTopic.length,
              scrollDirection: Axis.vertical,
              onPageChanged: (value) {
                if (value == listTopic.length - 1) {
                  var createdAt = listTopic[value].createdAt;
                  getNextTopic(createdAt).then((value) {
                    listTopic.addAll(value);
                    _streamController.sink.add(listTopic);
                  });
                }
              },
              itemBuilder: (context, index) {
                return Preview(
                  topic: listTopic[index],
                  isPushed: false,
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
