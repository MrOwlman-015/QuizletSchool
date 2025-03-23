import 'package:curved_bottom_navigation/API/file.dart';
import 'package:curved_bottom_navigation/API/folder.dart';
import 'package:curved_bottom_navigation/API/topic.dart';
import 'package:curved_bottom_navigation/API/word.dart';
import 'package:curved_bottom_navigation/Class/Folder.dart';
import 'package:curved_bottom_navigation/Class/Topic.dart';
import 'package:curved_bottom_navigation/Post/FlashCard.dart';
import 'package:curved_bottom_navigation/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'AddTopicScreen.dart';

class ListViewFolder extends StatefulWidget {
  const ListViewFolder(
      {super.key, required this.idFolder, required this.isPush});
  final bool isPush;
  final String idFolder;

  @override
  State<ListViewFolder> createState() => _ListViewFolderState();
}

class _ListViewFolderState extends State<ListViewFolder> {
  late Future<bool> isLoaded;
  bool isEditting = false;
  List<bool> isEditList = [];
  List<TextEditingController> listControll = [];
  List<String> listName = [];
  List<bool> isFolder = [];
  List<Folder> folders = [];
  List<Topic> topics = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoaded = getFilesByParentFolder(widget.idFolder).then((value) {
      Map<String, dynamic> files = value;
      folders = files["folders"];
      topics = files["topics"];

      for (var folder in folders) {
        isEditList.add(false);
        listControll.add(TextEditingController());
        listName.add(folder.name);
        isFolder.add(true);
      }

      for (var topic in topics) {
        isEditList.add(false);
        listControll.add(TextEditingController());
        listName.add(topic.name);
        isFolder.add(false);
      }
    }).then((value) => true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        int index = -1;

        setState(() {
          if (isEditting && MediaQuery.of(context).viewInsets.bottom == 0) {
            for (int i = 0; i < isEditList.length; i++) {
              if (isEditList[i]) {
                index = i;
                listName[i] = listControll[i].text;
                isEditList[i] = false;
                isEditting = false;
                break;
              }
            }
          }
          isEditList.clear();
          listControll.clear();
          listName.clear();
          isFolder.clear();
          for (var folder in folders) {
            isEditList.add(false);
            listControll.add(TextEditingController());
            listName.add(folder.name);
            isFolder.add(true);
          }

          for (var topic in topics) {
            isEditList.add(false);
            listControll.add(TextEditingController());
            listName.add(topic.name);
            isFolder.add(false);
          }
        });

        if (index >= 0) {
          Folder folder = folders[index];
          folder.name = listName[index];
          await updateFolder(folder);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: (widget.isPush)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
        ),
        backgroundColor: Colors.black,
        body: FutureBuilder(
          future: isLoaded,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                    "Error in loading folders and topics: ${snapshot.error}"),
              );
            }

            if (snapshot.hasData) {
              return GridView.builder(
                itemBuilder: (context, index) {
                  return _buildFolderItem(context, index);
                },
                itemCount: isEditList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 0.8),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.folder),
              label: "New Folder",
              onTap: () async {
                Folder addedFolder = Folder(
                  id: const Uuid().v4(),
                  name: "New Folder",
                  topics: [],
                  folders: [],
                  idMaster: context.read<MyStore>().user.id,
                );
                await addFolder(
                  addedFolder,
                );

                await getFolderByID(widget.idFolder).then((value) {
                  value.folders.add(addedFolder.id);
                  return value;
                }).then((value) {
                  updateFolder(value);
                }).catchError((error) {
                  print(error);
                });

                setState(() {
                  isEditting = true;
                  TextEditingController newFolder = TextEditingController();
                  newFolder.text = "New Folder";
                  listControll.add(newFolder);
                  listName.add("New Folder");
                  isEditList.add(true);
                  isFolder.add(true);
                  folders.add(addedFolder);
                });
              },
            ),
            SpeedDialChild(
                child: Icon(Icons.file_present_outlined),
                label: "New Topic",
                onTap: () async {
                  try {
                    Topic topic = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTopicScreen(
                          importCsv: false,
                          edit: false,
                        ),
                      ),
                    );

                    await getFolderByID(widget.idFolder).then((value) {
                      value.topics.add(topic.id);
                      return value;
                    }).then((value) {
                      updateFolder(value);
                    });

                    setState(() {
                      isEditting = true;
                      TextEditingController newFolder = TextEditingController();
                      newFolder.text = topic.name;
                      listControll.add(newFolder);
                      listName.add(topic.name);
                      isEditList.add(true);
                      isFolder.add(false);
                      topics.add(topic);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Add topic into folder successfully!",
                        ),
                      ),
                    );
                  } catch (e) {}
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderItem(BuildContext context, int index) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          if (!isEditting) {
            isEditList[index] = true;
            isEditting = true;
            listControll[index].text = listName[index];
          } else {
            for (int i = 0; i < isEditList.length; i++) {
              if (isEditList[i]) {
                listName[i] = listControll[i].text;
                isEditList[i] = false;
                isEditList[index] = true;
                listControll[index].text = listName[index];
                break;
              }
            }
          }
        });
      },
      onTap: () {
        if (isFolder[index]) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListViewFolder(
                idFolder: folders[index].id,
                isPush: true,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashCard(
                topic: topics[index - folders.length],
                isPushed: true,
              ),
            ),
          );
        }
      },
      child: Container(
        child: Column(
          children: [
            Stack(children: [
              (isFolder[index]
                  ? Icon(
                      Icons.folder,
                      color: Colors.white,
                      size: 100,
                    )
                  : Image.network(
                      "https://i.ytimg.com/vi/xorYi2I-FLk/maxresdefault.jpg",
                      width: 100,
                      height: 100,
                      fit: BoxFit.fitHeight,
                    )),
              (isEditList[index]
                  ? Container(
                      width: 100,
                      height: 100,
                      alignment: Alignment(1, -1),
                      child: IconButton(
                        color: Colors.red,
                        onPressed: () async {
                          String isApprove = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: (isFolder[index])
                                    ? const Text(
                                        "Do you want to delete this folder")
                                    : const Text(
                                        "Do you want to delete this folder"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  )
                                ],
                              );
                            },
                          ) as String;

                          if (isApprove == "OK") {
                            if (isFolder[index]) {
                              await deleteFolderByID(folders[index].id)
                                  .then((value) {
                                getFolderByID(widget.idFolder).then((value) {
                                  value.folders.remove(folders[index].id);
                                  return value;
                                }).then((value) {
                                  updateFolder(value);
                                }).then((value) {
                                  setState(() {
                                    isEditList.remove(isEditList[index]);
                                    listControll.remove(listControll[index]);
                                    listName.remove(listName[index]);
                                    folders.remove(folders[index]);
                                    isFolder.remove(isFolder[index]);
                                  });
                                });
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Delete folder successfully!",
                                  ),
                                ),
                              );
                            } else {
                              Topic topic = topics[index - folders.length];
                              await getWordsByTopic(topic.id)
                                  .then((value) async {
                                for (var word in value) {
                                  await deleteWordByID(word.id);
                                }
                              }).then((value) {
                                getFolderByID(widget.idFolder).then((value) {
                                  value.topics.remove(topic.id);
                                  return value;
                                }).then((value) {
                                  updateFolder(value);
                                }).then((value) {
                                  deleteTopicByID(topic.id);
                                }).then((value) {
                                  setState(() {
                                    isEditList.remove(isEditList[index]);
                                    listControll.remove(listControll[index]);
                                    listName.remove(listName[index]);
                                    topics
                                        .remove(topics[index - folders.length]);
                                    isFolder.remove(isFolder[index]);
                                  });
                                });
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Delete topic successfully!",
                                  ),
                                ),
                              );
                            }
                          }
                        }, //Xoa folder + topic
                        icon: Icon(Icons.close),
                      ),
                    )
                  : SizedBox()),
            ]),
            isFolder[index]
                ? Visibility(
                    child: TextField(
                      controller: listControll[index],
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    replacement: Text(
                      listName[index],
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    visible: isEditList[index],
                  )
                : Text(
                    listName[index],
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
          ],
        ),
      ),
    );
  }
}
