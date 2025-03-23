import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_bottom_navigation/Class/User.dart';
import 'package:curved_bottom_navigation/Page/WelcomePage.dart';
import 'package:curved_bottom_navigation/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Page/HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MyStore(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyStore with ChangeNotifier, DiagnosticableTreeMixin {
  Users user = Users(
    id: "d85646d3-063e-444b-a1a0-f1fac57b3195",
    name: "Nguyen Huu Tin",
    email: "nguyenhuutin124@gmail.com",
    folderID: "51feed88-7c40-4fd1-88b8-d717ea8565e4",
    bookMarkFolder: "bookmark_topics",
    favoriteTopics: ["17ff57f5-975e-4737-a766-4dfaebdcc42c"],
    favoriteWords: [],
  );

  void updateUser(Users newUser) {
    user = newUser;
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty("user", user));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    if (email != null && password != null) {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      try {
        final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final docSnap = await docRef.get();

        if (docSnap.exists) {
          final userData = docSnap.data();

          Users  user = Users.fromMap(uid, userData!);


          Provider.of<MyStore>(context, listen: false).updateUser(user);
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }


    }
  }

  @override
  Widget build(BuildContext context) {
    _checkLoginStatus(context); // Call the function to check login status

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<MyStore>(
        builder: (context, myStore, _) {
          // Determine which page to show based on login status
          return myStore.user.id != "d85646d3-063e-444b-a1a0-f1fac57b3195" ? const HomePage() : const WelcomePage();
        },
      ),
    );
  }
}
