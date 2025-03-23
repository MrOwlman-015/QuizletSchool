import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_bottom_navigation/Class/LearningProcess.dart';

Future<LearningProcess?> getLearningProcessByUserAndTopic(
    String userID, String topicID) async {
  try {
    QuerySnapshot<Map<String, dynamic>> response = await FirebaseFirestore
        .instance
        .collection("learning_processes")
        .where("idUser", isEqualTo: userID)
        .where("idTopic", isEqualTo: topicID)
        .get();

    if (response.docs.isNotEmpty) {
      return LearningProcess.fromMap(
          response.docs[0].id, response.docs[0].data());
    }
    return null;
  } catch (e) {
    throw Exception("Failed in loading learning process");
  }
}

Future<void> addLearningProcess(LearningProcess learningProcess) async {
  try {
    await FirebaseFirestore.instance
        .collection("learning_processes")
        .doc(learningProcess.id)
        .set(
          learningProcess.toMap(),
        );
    print("Add learning process successfully!");
  } catch (e) {
    throw Exception("Failed in adding learning process!");
  }
}

Future<void> updateLearningProcess(LearningProcess learningProcess) async {
  try {
    await FirebaseFirestore.instance
        .collection("learning_processes")
        .doc(learningProcess.id)
        .update(learningProcess.toMap());
  } catch (e) {
    throw Exception("Failed in updating learning process: $e");
  }
}
