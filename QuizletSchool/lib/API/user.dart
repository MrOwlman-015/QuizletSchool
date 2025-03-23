import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_bottom_navigation/Class/User.dart';

Future<Users> getUserByID(String id) async {
  try {
    DocumentSnapshot response =
        await FirebaseFirestore.instance.collection("users").doc(id).get();

    return Users.fromMap(id, response.data() as Map<String, dynamic>);
  } catch (e) {
    throw Exception("Failed in loading user: $e");
  }
}

Future<void> updateUser(Users user) async {
  try {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.id)
        .set(user.toMap());
  } catch (e) {
    throw Exception("Failed in updating user");
  }
}
