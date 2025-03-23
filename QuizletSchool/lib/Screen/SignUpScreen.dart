import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_bottom_navigation/Class/Folder.dart';
import 'package:curved_bottom_navigation/Screen/SignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../Class/User.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isRePasswordVisible = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.black,
                Colors.green,
              ]),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                "Don't Have Account!\nSign Up Here",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Colors.white,
                ),
                height: MediaQuery.of(context).size.height - 200,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Gmail",
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color.fromRGBO(1, 50, 20, 1),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                            labelText: "Password",
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color.fromRGBO(1, 50, 20, 1),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _repeatPasswordController,
                          obscureText: !_isRePasswordVisible,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isRePasswordVisible = !_isRePasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isRePasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                            labelText: "Repeat Password",
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color.fromRGBO(1, 50, 20, 1),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : Container(
                          height: 60,
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(colors: [
                              Colors.green,
                              Colors.black,
                            ]),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                setState(() {
                                  _isLoading = true;
                                });
                                signUp();
                              }
                            },
                            child: const Text(
                              'SIGN UP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 120),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("Already have an account?"),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const LoginPage()),
                                  );
                                },
                                child: const Text(
                                  "Sign in here",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void signUp() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await userCredential.user!.sendEmailVerification();

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your email before signing in.'),
        ),
      );

      await createUserInFirestore(userCredential.user);

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'An unknown error occurred.';
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Up Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }



  // void signUp() async {
  //   try {
  //     UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: _emailController.text,
  //       password: _passwordController.text,
  //     );
  //
  //     // Create a new user in Firestore
  //     await createUserInFirestore(userCredential.user);
  //
  //     setState(() {
  //       _isLoading = false;
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Successfully signed up!'),
  //       ),
  //     );
  //     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
  //   } on FirebaseAuthException catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     String errorMessage;
  //     switch (e.code) {
  //       case 'email-already-in-use':
  //         errorMessage = 'The email address is already in use.';
  //         break;
  //       case 'invalid-email':
  //         errorMessage = 'The email address is not valid.';
  //         break;
  //       case 'weak-password':
  //         errorMessage = 'The password is too weak.';
  //         break;
  //       default:
  //         errorMessage = 'An unknown error occurred.';
  //     }
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Sign Up Error'),
  //         content: Text(errorMessage),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  Future<void> createUserInFirestore(User? firebaseUser) async {
    if (firebaseUser == null) return;

    String folderId = const Uuid().v4();
    var shortUuid = const Uuid().v4().substring(0, 10);
    String name = "User$shortUuid";
    Folder folder = Folder(id: folderId,
    name: name,
    idMaster: firebaseUser.uid,
    folders: [],
    topics: []);

    final folderMap = folder.toMap();

    final user = Users(
      id: firebaseUser.uid,
      name: name,
      email: firebaseUser.email!,
      bookMarkFolder: 'bookmark_topics',
      folderID: folderId,
      avatarUrl: '',
      favoriteTopics: [],
      favoriteWords: [],
    );

    final userMap = user.toMap();

    await FirebaseFirestore.instance.collection('users').doc(user.id).set(userMap);
    await FirebaseFirestore.instance.collection('folders').doc(folderId).set(folderMap);
  }
}

// class Users {
//   final String id, name, email, bookMarkFolder, folderID;
//   String? avatarUrl;
//   List<String> favoriteTopics = [];
//   List<String> favoriteWords = [];
//
//   Users({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.bookMarkFolder,
//     required this.folderID,
//     this.avatarUrl,
//     required this.favoriteTopics,
//     required this.favoriteWords,
//   });
//
//   factory Users.fromMap(String id, Map<String, dynamic> map) => Users(
//     id: id,
//     name: map["name"],
//     email: map["email"],
//     avatarUrl: map["avatarUrl"] ?? "",
//     folderID: map["folderID"],
//     bookMarkFolder: "bookmark_topics",
//     favoriteTopics: List.from(map["favoriteTopics"]),
//     favoriteWords: List.from(map["favoriteWords"]),
//   );
//
//   Map<String, dynamic> toMap() {
//     return {
//       "id": id,
//       "name": name,
//       "email": email,
//       "avatarUrl": avatarUrl,
//       "favoriteTopics": favoriteTopics,
//       "favoriteWords": favoriteWords,
//     };
//   }
// }
