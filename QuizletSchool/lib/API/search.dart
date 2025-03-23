import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_bottom_navigation/Class/Topic.dart';
import 'package:curved_bottom_navigation/Class/Word.dart';

Future<List<String>> getSuggestionString(String searchValue) async {
  searchValue = searchValue.toLowerCase();
  try {
    List<String> suggestions = [];
    QuerySnapshot<Map<String, dynamic>> topicUpperResponse =
        await FirebaseFirestore.instance
            .collection("topics")
            .where("name", isGreaterThanOrEqualTo: searchValue)
            .where("name", isLessThan: '$searchValue\uf8ff')
            .get();

    for (var doc in topicUpperResponse.docs) {
      suggestions.add(Topic.fromMap(doc.id, doc.data()).name);
    }

    QuerySnapshot<Map<String, dynamic>> wordUpperResponse =
        await FirebaseFirestore.instance
            .collection("words")
            .where("english", isGreaterThanOrEqualTo: searchValue)
            .where("english", isLessThan: '$searchValue\uf8ff')
            .get();
    for (var doc in wordUpperResponse.docs) {
      suggestions.add(Word.fromMap(doc.id, doc.data()).english);
    }

    return suggestions;
  } catch (e) {
    throw Exception('Failed in loading suggestion: $e');
  }
}

Future<Map<String, dynamic>> getSuggestion(String searchValue) async {
  searchValue = searchValue.toLowerCase();
  try {
    Map<String, dynamic> suggestions = {};
    List<Topic> topics = [];
    List<Word> words = [];

    QuerySnapshot<Map<String, dynamic>> topicUpperResponse =
        await FirebaseFirestore.instance
            .collection("topics")
            .where("name", isGreaterThanOrEqualTo: searchValue)
            .where("name", isLessThan: '$searchValue\uf8ff')
            .get();

    for (var doc in topicUpperResponse.docs) {
      topics.add(Topic.fromMap(doc.id, doc.data()));
    }
    suggestions.addAll({"topics": topics});

    QuerySnapshot<Map<String, dynamic>> wordUpperResponse =
        await FirebaseFirestore.instance
            .collection("words")
            .where("english", isGreaterThanOrEqualTo: searchValue)
            .where("english", isLessThan: '$searchValue\uf8ff')
            .get();
    for (var doc in wordUpperResponse.docs) {
      words.add(Word.fromMap(doc.id, doc.data()));
    }
    suggestions.addAll({"words": words});

    return suggestions;
  } catch (e) {
    throw Exception('Failed in loading suggestion: $e');
  }
}
