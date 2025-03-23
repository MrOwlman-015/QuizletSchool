import 'dart:io';

import 'package:curved_bottom_navigation/API/folder.dart';
import 'package:curved_bottom_navigation/API/user.dart';
import 'package:curved_bottom_navigation/Class/Folder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_bottom_navigation/Screen/SignInScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../API/result.dart';
import '../API/topic.dart';
import '../Class/Result.dart';
import '../Class/Topic.dart';
import '../Class/User.dart';
import '../main.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _isSigningOut = false;
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();

  File? imageFile;
  String imageName = "";

  List<Result>? listResult = [];
  List<Topic>? listTopic = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = context.read<MyStore>().user.name ?? '';
    _loadTopResults();
  }

  Future<void> _loadTopResults() async {
    Users user = context.read<MyStore>().user;
    if (user != null) {
      List<Result> results = await getResultsByUserID(user.id);
      results.sort((a, b) {
        int scoreComparison = b.score.compareTo(a.score);
        if (scoreComparison != 0) {
          return scoreComparison;
        }
        return a.time.compareTo(b.time);
      });
      List<Result> top5Results = results.take(5).toList();

      for (Result res in top5Results) {
        Topic topic = await getTopicByID(res.idTopic);
        listTopic?.add(topic);
      }

      setState(() {
        listResult = top5Results;
      });
    }
  }

  // Future<void> _signOut() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('email');
  //   await prefs.remove('password');
  //   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  // }

  Future<void> _signOut() async {
    setState(() {
      _isSigningOut = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');

    await FirebaseAuth.instance.signOut();

    setState(() {
      _isSigningOut = false;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  Future<void> _updateName() async {
    String newName = _nameController.text;
    Folder folder = await getFolderByID(context.read<MyStore>().user.folderID);
    folder.name = newName;
    await updateFolder(folder);

    setState(() {
      context.read<MyStore>().user.name = newName;
      updateUser(context.read<MyStore>().user);
      _isEditing = false;
    });
  }

  Future<void> _uploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        setState(() {
          imageFile = File(file.path!);
          imageName = context.read<MyStore>().user.id;
        });

        _updateAvatar();
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _updateAvatar() async {
    try {
      if (imageFile != null) {
        Users user = context.read<MyStore>().user;
        final storageRef = FirebaseStorage.instance
            .ref("images/avatars/${user.id}/${user.id}");

        final SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': imageFile!.path},
        );

        TaskSnapshot taskSnapshot =
            await storageRef.putFile(imageFile!, metadata);

        String downloadURL = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          context.read<MyStore>().user.avatarUrl = downloadURL;
          updateUser(context.read<MyStore>().user);
        });

        await FirebaseAuth.instance.currentUser!.updatePhotoURL(downloadURL);

        print('Image uploaded successfully.');
      } else {
        print('No image selected.');
      }
    } catch (error) {
      print('Failed to upload image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Users user = context.read<MyStore>().user;
    return Container(
      color: Colors.black,
      child: Center(
        child: user == null
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      color: Colors.green.withOpacity(0.4),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: SizedBox(
                                  width: 100.0,
                                  height: 100.0,
                                  child: user.avatarUrl != ''
                                      ? Image.network(
                                          user.avatarUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Image(
                                          image: AssetImage(
                                              'assets/images/avatar.png'),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                user.email ?? 'No email',
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _isEditing
                                    ? Expanded(
                                        child: TextFormField(
                                          controller: _nameController,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        user.name ?? 'No name',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                SizedBox(width: 10),
                                _isEditing
                                    ? IconButton(
                                        onPressed: _updateName,
                                        icon: Icon(Icons.check),
                                        color: Colors.white,
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isEditing = true;
                                          });
                                        },
                                        icon: Icon(Icons.edit),
                                        color: Colors.white,
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      color: Colors.green.withOpacity(0.4),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: Text(
                                'Achievements',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (listResult != null && listTopic != null)
                              ...List.generate(listResult!.length, (index) {
                                return Text(
                                  'Topic: ${listTopic![index].name}, Score: ${listResult![index].score}, Time: ${listResult![index].time}, Type: ${listResult![index].type}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      // New Row for buttons
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly, // Align buttons evenly
                      children: [
                        ElevatedButton(
                          onPressed: _uploadImage,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.orange,
                          ),
                          child: Text('Change Avatar'),
                        ),
                        ElevatedButton(
                          onPressed: _showChangePasswordDialog,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.orange,
                          ),
                          child: Text('Change Password'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _isSigningOut || _isEditing
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _signOut,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Sign Out'),
                          ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    String oldPassword = '';
    String newPassword = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                    labelText: 'Old Password',
                    labelStyle: TextStyle(color: Colors.white)),
                onChanged: (value) {
                  oldPassword = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: Colors.white)),
                onChanged: (value) {
                  newPassword = value;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _changePassword(oldPassword, newPassword);
                Navigator.of(context).pop();
              },
              child: Text('Done', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  void _changePassword(String oldPassword, String newPassword) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: FirebaseAuth.instance.currentUser!.email!,
        password: oldPassword,
      );
      await userCredential.user!.updatePassword(newPassword);
      print('Password updated successfully.');
    } on FirebaseAuthException catch (e) {
      print('Failed to update password: $e');
    }
  }
}
