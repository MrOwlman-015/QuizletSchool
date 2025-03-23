import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_bottom_navigation/API/topic.dart';
import 'package:curved_bottom_navigation/Class/Folder.dart';
import 'package:curved_bottom_navigation/Class/User.dart';


Future<Folder> getFolderByID(String id) async {
  try {
    DocumentSnapshot response =
        await FirebaseFirestore.instance.collection("folders").doc(id).get();

    Folder folder = Folder.fromMap(id, response.data() as Map<String, dynamic>);

    for (var topic in folder.topics) {
      var data = await getTopicByID(topic);

      folder.detailTopic.add(data);
    }

    return folder;
  } catch (e) {
    throw Exception("Failed in loading folder: $e");
  }
}

Future<void> addFolder(Folder folder) async {
  try {
    await FirebaseFirestore.instance
        .collection("folders")
        .doc(folder.id)
        .set(folder.toMap());
  } catch (e) {
    throw Exception("Failed in adding folder: $e");
  }
}

Future<Folder> getBookmarkTopic(Users user) async {
  try {
    Folder folder = Folder(
        id: user.bookMarkFolder,
        name: "Bookmark topics",
        topics: user.favoriteTopics,
        folders: [],
        idMaster: user.id);

    for (var topicID in user.favoriteTopics) {
      var topic = await getTopicByID(topicID);
      print(topic);
      folder.detailTopic.add(topic);
    }

    return folder;
  } catch (e) {
    throw Exception("Failed in loading bookmark topics: $e");
  }
}

Future<void> updateFolder(Folder folder) async {
  try {
    await FirebaseFirestore.instance
        .collection("folders")
        .doc(folder.id)
        .set(folder.toMap());

    print("Update successfully!");
  } catch (e) {
    throw Exception("Failed in updating folder: $e");
  }
}

Future<void> deleteFolderByID(String id) async {
  try {
    await FirebaseFirestore.instance.collection("folders").doc(id).delete();
  } catch (e) {
    throw Exception("Failed in deleting folder: $e");
  }
}
