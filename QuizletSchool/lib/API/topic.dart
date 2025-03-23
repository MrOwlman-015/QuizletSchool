import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_bottom_navigation/Class/Topic.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<List<Topic>> getTopics() async {
  try {
    QuerySnapshot<Map<String, dynamic>> response = await FirebaseFirestore
        .instance
        .collection("topics")
        .where("isPublic", isEqualTo: true)
        .orderBy("createdAt", descending: true)
        .limit(4)
        .get();

    List<Topic> topics = [];
    for (var topic in response.docs) {
      var id = topic.id;
      Topic tc = Topic.fromMap(id, topic.data());

      if (tc.imageName != null) {
        if (tc.imageName!.isNotEmpty) {
          await FirebaseStorage.instance
              .ref("images/topics/${tc.imageName}")
              .getDownloadURL()
              .then((value) => {tc.imageUrl = value});
        }
      }
      topics.add(tc);
    }
    return topics;
  } catch (e) {
    throw Exception("Failed in loading topics: $e");
  }
}

Future<List<Topic>> getNextTopic(DateTime createdAt) async {
  try {
    QuerySnapshot<Map<String, dynamic>> response = await FirebaseFirestore
        .instance
        .collection("topics")
        .where("isPublic", isEqualTo: true)
        .orderBy("createdAt", descending: true)
        .startAfter([createdAt])
        .limit(1)
        .get();
    List<Topic> topics = [];
    for (var topic in response.docs) {
      var id = topic.id;
      topics.add(Topic.fromMap(id, topic.data()));
    }
    return topics;
  } catch (e) {
    throw Exception("Failed in loading topic: $e");
  }
}

Future<Topic> getTopicByID(String id) async {
  try {
    DocumentSnapshot response =
        await FirebaseFirestore.instance.collection("topics").doc(id).get();

    return Topic.fromMap(id, response.data() as Map<String, dynamic>);
  } catch (e) {
    throw Exception("Failed in loading topics by folder: $e");
  }
}

Future<void> addTopic(Topic topic) async {
  try {
    await FirebaseFirestore.instance
        .collection("topics")
        .doc(topic.id)
        .set(topic.toMap());
  } catch (e) {
    throw Exception("Failed in adding topic: $e");
  }
}

Future<void> updateTopic(Topic topic) async {
  try {
    await FirebaseFirestore.instance
        .collection("topics")
        .doc(topic.id)
        .set(topic.toMap());
  } catch (e) {
    throw Exception('Failed in updating topic: $e');
  }
}

Future<void> deleteTopicByID(String id) async {
  try {
    await FirebaseFirestore.instance.collection("topics").doc(id).delete();
  } catch (e) {
    throw Exception("Failed in deleting topic: $e");
  }
}
