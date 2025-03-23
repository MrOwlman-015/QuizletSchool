import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_bottom_navigation/API/folder.dart';
import 'package:curved_bottom_navigation/API/topic.dart';
import 'package:curved_bottom_navigation/Class/Folder.dart';

Future<Map<String, dynamic>> getFilesByParentFolder(String folderID) async {
  try {
    DocumentSnapshot response = await FirebaseFirestore.instance
        .collection("folders")
        .doc(folderID)
        .get();

    Folder folder =
        Folder.fromMap(folderID, response.data() as Map<String, dynamic>);

    for (var topic in folder.topics) {
      var data = await getTopicByID(topic);

      folder.detailTopic.add(data);
    }

    for (var subFolder in folder.folders) {
      var data = await getFolderByID(subFolder);

      folder.detailFolder.add(data);
    }

    Map<String, dynamic> files = {};

    files.addAll({"folders": folder.detailFolder});
    files.addAll({"topics": folder.detailTopic});

    return files;
  } catch (e) {
    throw Exception("Failed in loading file: $e");
  }
}
