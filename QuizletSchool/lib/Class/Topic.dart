import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_bottom_navigation/Class/Word.dart';

class Topic {
  final String id;
  String name, idMaster, description, authorName;
  String? imageName, imageUrl;
  DateTime createdAt;
  bool isPublic = false;
  List<String>? idLearners = [];
  List<Word>? words = [];
  Topic(
      {required this.id,
      required this.name,
      required this.idMaster,
      required this.description,
      required this.authorName,
      required this.createdAt,
      required this.isPublic,
      this.idLearners,
      this.imageName,});
  factory Topic.fromMap(String id, Map<String, dynamic> map) => Topic(
      id: id,
      name: map["name"].toString().toUpperCase(),
      idMaster: map["idMaster"],
      description: map["description"],
      authorName: map["authorName"],
      createdAt: (map["createdAt"] as Timestamp).toDate(),
      isPublic: map["isPublic"],
      idLearners: map["idLearner"] ?? [],
      imageName: map["imageName"] ?? "",
    );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name.toLowerCase(),
      "idMaster": idMaster,
      "authorName": authorName,
      "description": description,
      "createdAt": createdAt,
      "isPublic": isPublic,
      "idLearners": idLearners,
      "imageName": imageName ?? "",
    };
  }
}
