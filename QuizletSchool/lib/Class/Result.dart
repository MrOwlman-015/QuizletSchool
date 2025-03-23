import 'package:cloud_firestore/cloud_firestore.dart';

class Result {
  final String id, idTopic, idUser, type;
  int time, score;
  DateTime completedAt;

  Result({
    required this.id,
    required this.idTopic,
    required this.idUser,
    required this.time,
    required this.score,
    required this.type,
    required this.completedAt,
  });

  factory Result.fromMap(String id, Map<String, dynamic> map) => Result(
      id: id,
      idTopic: map["idTopic"],
      idUser: map["idUser"],
      time: map["time"],
      score: map["score"],
      type: map["type"],
      completedAt: (map["completedAt"] as Timestamp).toDate());

  Map<String, dynamic> toMap() {
    return {
      "idTopic": idTopic,
      "idUser": idUser,
      "time": time,
      "score": score,
      "type": type,
      "completedAt": completedAt,
    };
  }
}
