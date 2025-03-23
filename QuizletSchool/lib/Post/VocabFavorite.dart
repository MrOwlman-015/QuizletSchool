import 'package:curved_bottom_navigation/API/word.dart';
import 'package:curved_bottom_navigation/Class/User.dart';
import 'package:curved_bottom_navigation/Class/Word.dart';
import 'package:curved_bottom_navigation/main.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VocabFavourite extends StatefulWidget {
  const VocabFavourite({super.key});

  @override
  State<VocabFavourite> createState() => _VocabFavouriteState();
}

class _VocabFavouriteState extends State<VocabFavourite> {
  List<String> english = [];
  List<String> vietnamese = [];
  @override
  Widget build(BuildContext context) {
    Users user = context.read<MyStore>().user;
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: getFavoriteWordsByIDs(user.favoriteWords),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error in loading favorite words: ${snapshot.error}"),
            );
          }

          if (snapshot.hasData) {
            List<Word> words = snapshot.data!;

            for (var word in words) {
              english.add(word.english);
              vietnamese.add(word.vietnamese);
            }
            return GridView.builder(
              itemBuilder: (context, index) {
                return _buildVocabItem(context, index);
              },
              itemCount: words.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.8),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildVocabItem(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
      child: FlipCard(
        front: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.3,
            alignment: Alignment.center,
            color: Colors.green,
            child: Text(
              english[index],
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            )),
        back: Container(
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.height * 0.3,
          alignment: Alignment.center,
          color: Colors.green,
          child: Text(
            vietnamese[index],
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
