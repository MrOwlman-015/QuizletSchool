import 'package:curved_bottom_navigation/API/search.dart';
import 'package:curved_bottom_navigation/Class/Topic.dart';
import 'package:curved_bottom_navigation/Class/Word.dart';
import 'package:curved_bottom_navigation/Post/FlashCard.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SearchScreen extends StatefulWidget {
  final String searchWord;

  const SearchScreen({super.key, required this.searchWord});
  @override
  State<StatefulWidget> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  List<Topic> listTopic = [];
  List<Word> listtWord = [];
  String searchText = "";

  FlutterTts tts = FlutterTts();
  Future<List<String>> _fetchSuggestions(String searchValue) async {
    await Future.delayed(const Duration(milliseconds: 750));

    List<String> result = await getSuggestionString(searchValue);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: EasySearchBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.searchWord,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onSearch: (value) => setState(() => searchText = value),
        onSuggestionTap: (data) {},
        iconTheme: IconThemeData(color: Colors.white),
        asyncSuggestions: (value) async => await _fetchSuggestions(value),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          alignment: Alignment(-1, 1),
          child: FutureBuilder(
            future: getSuggestion(widget.searchWord),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                      "Error in loading topics and words: ${snapshot.error}"),
                );
              }

              if (snapshot.hasData) {
                Map<String, dynamic> map = snapshot.data!;

                listTopic = map["topics"];
                listtWord = map["words"];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment(-1, 1),
                              child: Text(
                                "Topic",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 30),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.width * 1,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return _buildTopicItems(context, index);
                                },
                                itemCount: listTopic.length,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment(-1, 1),
                              child: Text(
                                "Word",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 30),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.width * 1,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return _buildVocabItem(context, index);
                                },
                                itemCount: listtWord.length,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ],
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
          ),
        ),
      ),
    );
  }

  Widget _buildTopicItems(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlashCard(
              topic: listTopic[index],
              isPushed: true,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 1,
              width: MediaQuery.of(context).size.width * 0.4,
              alignment: Alignment.center,
              child: Image.network(
                "https://i.ytimg.com/vi/xorYi2I-FLk/maxresdefault.jpg",
                fit: BoxFit.fitHeight,
              ),
            ),
            Container(
              color: Colors.grey.withOpacity(0.4),
              height: MediaQuery.of(context).size.height * 1,
              width: MediaQuery.of(context).size.width * 0.4,
              alignment: Alignment.center,
              child: Text(
                listTopic[index].name,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVocabItem(BuildContext context, int index) {
    return Container(
        margin: const EdgeInsets.all(10),
        child: FlipCard(
            front: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 1,
                alignment: Alignment.center,
                color: Colors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.volume_up),
                      iconSize: 30,
                      color: Colors.white,
                      onPressed: () {
                        tts.setLanguage('en-US');
                        _speak(listtWord[index].english);
                      },
                    ),
                    Text(
                      listtWord[index].english,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )),
            back: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 1,
                alignment: Alignment.center,
                color: Colors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.volume_up),
                      iconSize: 30,
                      color: Colors.white,
                      onPressed: () {
                        tts.setLanguage('vi-VN');
                        _speak(listtWord[index].vietnamese);
                      },
                    ),
                    Text(
                      listtWord[index].vietnamese,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ))));
  }

  void _speak(String text) async {
    await tts.speak(text);
  }

  void _stop() async {
    await tts.stop();
  }
}
