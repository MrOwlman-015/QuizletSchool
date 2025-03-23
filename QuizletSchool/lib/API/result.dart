import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_bottom_navigation/Class/Result.dart';

Future<List<Result>> getResultByTopicIDAndType(String idTopic, type) async {
  try {
    QuerySnapshot<Map<String, dynamic>> response = await FirebaseFirestore
        .instance
        .collection("results")
        .where("idTopic", isEqualTo: idTopic)
        .where("type", isEqualTo: type)
        .get();
    List<Result> results = [];
    for (var doc in response.docs) {
      var id = doc.id;
      results.add(Result.fromMap(id, doc.data()));
    }
    results.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    results.sort((a, b) => a.time.compareTo(b.time));
    return results;
  } catch (e) {
    throw Exception("Failed in loading result: $e");
  }
}

Future<List<Result>> getResultsByUserID(String idUser) async {
  try {
    QuerySnapshot<Map<String, dynamic>> response =
        await FirebaseFirestore.instance
            .collection("results")
            .where("idUser", isEqualTo: idUser)
            // .orderBy("score", descending: true)
            // .orderBy("time")
            .get();
    List<Result> results = [];
    for (var doc in response.docs) {
      var id = doc.id;
      results.add(Result.fromMap(id, doc.data()));
    }
    return results;
  } catch (e) {
    throw Exception("Failed to load results: $e");
  }
}

Future<List<Result>> getTop5ResultsByUserID(String idUser) async {
  try {
    QuerySnapshot<Map<String, dynamic>> response = await FirebaseFirestore
        .instance
        .collection("results")
        .where("idUser", isEqualTo: idUser)
        .orderBy("score", descending: true)
        .orderBy("time")
        .limit(5)
        .get();
    List<Result> results = [];
    for (var doc in response.docs) {
      var id = doc.id;
      results.add(Result.fromMap(id, doc.data()));
    }
    return results;
  } catch (e) {
    throw Exception("Failed to load results: $e");
  }
}

Future<void> addResult(Result result) async {
  try {
    QuerySnapshot<Map<String, dynamic>> response = await FirebaseFirestore
        .instance
        .collection("results")
        .where("idUser", isEqualTo: result.idUser)
        .where("idTopic", isEqualTo: result.idTopic)
        .where("type", isEqualTo: result.type)
        .get();

    if (response.docs.isNotEmpty) {
      var doc = response.docs[0];
      Result addedResult = Result.fromMap(doc.id, doc.data());

      if (addedResult.time > result.time) {
        print("ID: ${response.docs.length}");
        addedResult.completedAt = result.completedAt;
        addedResult.score = result.score;
        addedResult.time = result.time;
        await FirebaseFirestore.instance
            .collection("results")
            .doc(addedResult.id)
            .set(addedResult.toMap());
      }
    } else {
      await FirebaseFirestore.instance
          .collection("results")
          .doc(result.id)
          .set(result.toMap());
    }
  } catch (e) {
    throw Exception("Failed in adding result: $e");
  }
}
