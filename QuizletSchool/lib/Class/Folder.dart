import 'package:curved_bottom_navigation/Class/Topic.dart';

class Folder {
  final String id;
  String name;
  List<String> folders;
  List<String> topics;
  final String idMaster;
  List<Topic> detailTopic = [];
  List<Folder> detailFolder = [];

  Folder({
    required this.id,
    required this.name,
    required this.topics,
    required this.folders,
    required this.idMaster,
  });

  factory Folder.fromMap(String id, Map<String, dynamic> map) => Folder(
      id: id,
      name: map["name"],
      topics: List.from(map["topics"]),
      folders: List.from(map["folders"]),
      idMaster: map["idMaster"]);

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "idMaster": idMaster,
      "name": name,
      "topics": topics,
      "folders": folders,
    };
  }
}
