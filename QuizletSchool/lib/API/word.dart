import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_bottom_navigation/Class/Word.dart';

Future<List<Word>> getWordsByTopic(String idTopic) async {
  try {
    QuerySnapshot<Map<String, dynamic>> response = await FirebaseFirestore
        .instance
        .collection("words")
        .where("idTopic", isEqualTo: idTopic)
        .get();
    List<Word> words = [];
    for (var doc in response.docs) {
      var id = doc.id;
      words.add(Word.fromMap(id, doc.data()));
    }
    return words;
  } catch (e) {
    throw Exception("Failed in loading words");
  }
}

Future<List<Word>> getFavoriteWordsByIDs(List<String> words) async {
  try {
    List<Word> favWord = [];
    for (var wordID in words) {
      DocumentSnapshot response = await FirebaseFirestore.instance
          .collection("words")
          .doc(wordID)
          .get();
      favWord.add(
          Word.fromMap(response.id, response.data() as Map<String, dynamic>));
    }

    return favWord;
  } catch (e) {
    throw Exception("Failed in favorite words: $e");
  }
}

Future<void> addWordSByTopic(Word word) async {
  try {
    await FirebaseFirestore.instance
        .collection("words")
        .doc(word.id)
        .set(word.toMap());
  } catch (e) {
    throw Exception("Failed in loading word: $e");
  }
}

Future<void> updateWord(Word word) async {
  try {
    await FirebaseFirestore.instance
        .collection("words")
        .doc(word.id)
        .set(word.toMap());
  } catch (e) {
    throw Exception("Failed in updating word: $e");
  }
}

Future<void> deleteWordByID(String id) async {
  try {
    await FirebaseFirestore.instance.collection("words").doc(id).delete();
  } catch (e) {
    throw Exception("Failed in deleting word: $e");
  }
}
