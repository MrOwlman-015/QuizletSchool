import 'package:curved_bottom_navigation/Post/AddTopicScreen.dart';
import 'package:curved_bottom_navigation/Screen/FolderScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../API/folder.dart';
import '../Class/Folder.dart';
import '../main.dart';

class AddingScreen extends StatefulWidget {
  const AddingScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => AddingScreenState();
}

class AddingScreenState extends State<AddingScreen> {

  Future<void> _createNewFolder() async {
    Folder addedFolder = Folder(
      id: const Uuid().v4(),
      name: "New Folder",
      topics: [],
      folders: [],
      idMaster: context.read<MyStore>().user.id,
    );

    await addFolder(addedFolder);

    await getFolderByID(context.read<MyStore>().user.folderID).then((value) {
      value.folders.add(addedFolder.id);
      return value;
    }).then((value) {
      updateFolder(value);
    }).catchError((error) {
      print(error);
    });

    ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Folder "${addedFolder.name}" created successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );



    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => FolderScreen(),
    //   ),
    // );
  }

  // Future<void> _createNewFolder() async {
  //   Folder addedFolder = Folder(
  //     id: const Uuid().v4(),
  //     name: "New Folder",
  //     topics: [],
  //     folders: [],
  //     idMaster: context.read<MyStore>().user.id,
  //   );
  //
  //   try {
  //     await addFolder(addedFolder);
  //
  //     await getFolderByID(context.read<MyStore>().user.folderID).then((value) {
  //       value.folders.add(addedFolder.id);
  //       return value;
  //     }).then((value) {
  //       updateFolder(value);
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Folder "${addedFolder.name}" created successfully!'),
  //         backgroundColor: Colors.green,
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //
  //     Navigator.pop(context); // Quay lại màn hình trước đó nếu cần thiết
  //
  //   } catch (error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to create folder: $error'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //     print(error);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTopicScreen(
                    importCsv: false,
                    edit: false,
                  ),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.15,
              margin: const EdgeInsets.only(
                  left: 30, top: 10, right: 30, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.red,
                    blurRadius: 4,
                    offset: Offset(4, 8), // Shadow position
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.only(left: 50, top: 10, bottom: 10),
                    child: Text(
                      "Topic",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 90),
                    child: Stack(children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: Image(
                          fit: BoxFit.fitHeight,
                          image: NetworkImage(
                              "https://images-ng.pixai.art/images/orig/68e23bf9-72e3-4c57-b9e9-efd690604659"),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 200,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            stops: [.1, .6],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              Colors.purple,
                              Colors.transparent, // top Right part
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _createNewFolder();
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.15,
              margin:
              const EdgeInsets.only(left: 30, top: 10, right: 30, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red,
                    blurRadius: 4,
                    offset: Offset(4, 8), // Shadow position
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 40),
                    child: Stack(children: [
                      Container(
                        child: Image(
                          fit: BoxFit.fitHeight,
                          image: NetworkImage(
                              "https://i.pinimg.com/736x/33/dd/24/33dd245ffc1e2307a2db868de3072ea1.jpg"),
                        ),
                      ),
                      Container(
                        width: 130,
                        height: 200,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            stops: [.1, .6],
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                            colors: [
                              Colors.green,
                              Colors.transparent, // top Right part
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 70, top: 10, bottom: 10),
                    child: Text(
                      "Folder",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTopicScreen(
                    importCsv: true,
                    edit: false,
                  ),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.15,
              margin: const EdgeInsets.only(
                  left: 30, top: 10, right: 30, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.red,
                    blurRadius: 4,
                    offset: Offset(4, 8), // Shadow position
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.only(left: 50, top: 10, bottom: 10),
                    child: const Text(
                      "Import CSV",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Stack(children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: Image(
                          fit: BoxFit.fitHeight,
                          image: NetworkImage(
                              "https://honkai-builds.com/wp-content/uploads/ruan-mei.webp"),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 200,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            stops: [.1, .6],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              Colors.blue,
                              Colors.transparent, // top Right part
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
