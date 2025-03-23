import 'dart:async';

import 'package:curved_bottom_navigation/API/topic.dart';
import 'package:curved_bottom_navigation/Post/FlashCard.dart';
import 'package:flutter/material.dart';

import '../Class/Topic.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late StreamController<List<Topic>> controller;
  final _controller = PageController();
  //Load topic

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = StreamController<List<Topic>>();
    _loadTopic();
  }

  void _loadTopic() async {
    getTopics().then((value) => controller.sink.add(value));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.black,
        body: StreamBuilder(
          stream: controller.stream,
          builder: (context, snapshot) {
            // if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Text(
                "Error in loading topics",
                style: TextStyle(
                  color: Colors.white,
                ),
              );
            }
            if (snapshot.hasData) {
              List<Topic> data = [];
              if (snapshot.data != null) {
                data = snapshot.data!;
              }
              return PageView.builder(
                itemCount: snapshot.data?.length,
                scrollDirection: Axis.vertical,
                onPageChanged: (value) {
                  if (value == data.length - 1) {
                    var createdAt = data[value].createdAt;
                    getNextTopic(createdAt).then((value) {
                      data.addAll(value);
                      controller.sink.add(data);
                    });
                  }
                },
                itemBuilder: (context, index) {
                  return FlashCard(
                    topic: data[index],
                    isPushed: false,
                  );
                },
              );
            }
            // }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
