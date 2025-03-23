import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:curved_bottom_navigation/API/folder.dart';
import 'package:curved_bottom_navigation/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:curved_bottom_navigation/API/topic.dart';
import 'package:curved_bottom_navigation/API/word.dart';
import 'package:curved_bottom_navigation/Class/Word.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../Class/Topic.dart';

class AddTopicScreen extends StatefulWidget {
  AddTopicScreen(
      {Key? key, required this.importCsv, required this.edit, this.topic})
      : super(key: key);
  Topic? topic;
  final bool edit;
  final bool importCsv;
  @override
  State<StatefulWidget> createState() => AddTopicScreenState();
}

class AddTopicScreenState extends State<AddTopicScreen> {
  TextEditingController _textNameTopicController = TextEditingController();
  final _nameFormKey = GlobalKey<FormState>();
  TextEditingController _textDesTopicController = TextEditingController();

  List<TextEditingController> _textEngController = [];
  List<TextEditingController> _textVieController = [];
  List<GlobalKey<FormState>> _formKeys = [];
  List<String> _idWord = [];
  List<String> _idRemove = [];
  late String filePath;
  File? imageFile;
  String imageName = "";
  int word = 0;
  bool isPrivate = true;
  bool isAdding = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.importCsv) {
      _pickFile();
    }
    if (widget.edit) {
      if (widget.topic != null) {
        isPrivate = !widget.topic!.isPublic;
        getWordsByTopic(widget.topic!.id).then((value) {
          loadForEdit(value, widget.topic!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () => handleClickDone(context),
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                child: Row(
                  children: [
                    const Text(
                      "Private",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SwitchExample(
                      isPrivate: (widget.topic != null)
                          ? !widget.topic!.isPublic
                          : isPrivate,
                      updateValue: updateState,
                    ),
                  ],
                ),
              ),
              Form(
                key: _nameFormKey,
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: TextFormField(
                    controller: _textNameTopicController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter topic's name";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      labelText: "Enter your Topic name",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                    ),
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.1,
                child: TextField(
                  controller: _textDesTopicController,
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    labelText: "Enter your Topic description",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                  ),
                  style: const TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        child: imageFile != null
                            ? Container(
                                width: MediaQuery.of(context).size.width * 1,
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image(
                                  fit: BoxFit.fitHeight,
                                  image: FileImage(imageFile!),
                                ),
                              )
                            : null,
                      ),
                      Container(
                        child: ElevatedButton(
                          onPressed: () {
                            _uploadImage();
                          },
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          child: const Text("Choose an image"),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      //Word
                      Container(
                        child: Column(
                          children: List.generate(
                            _textEngController.length,
                            (index) {
                              return Container(
                                width: MediaQuery.of(context).size.width * 1,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                margin: const EdgeInsets.only(
                                    left: 30, top: 25, right: 30, bottom: 25),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.green, Colors.black],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 40,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.2),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            removeTextField(index);
                                          });
                                        },
                                      ),
                                    ),
                                    Form(
                                      key: _formKeys[index],
                                      child: Column(
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            child: TextFormField(
                                              controller:
                                                  _textEngController[index],
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  print(value);
                                                  return "Please enter english meaning";
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                labelText: 'English Meaning',
                                                labelStyle: TextStyle(
                                                    color: Colors.white),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.cyan),
                                                ),
                                              ),
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 10),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            child: TextFormField(
                                              controller:
                                                  _textVieController[index],
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Please enter vietnamese meaning";
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                labelText: 'Vietnamese Meaning',
                                                labelStyle: TextStyle(
                                                    color: Colors.white),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.cyan),
                                                ),
                                              ),
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      //Button
                      Center(
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.height * 0.05,
                          margin: const EdgeInsets.only(
                              left: 5, top: 1, right: 5, bottom: 1),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  addTextField();
                                },
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isAdding)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration:
                  BoxDecoration(color: Color.fromRGBO(100, 100, 100, 0.5)),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void addTextField() {
    TextEditingController controllerE = TextEditingController();
    TextEditingController controllerV = TextEditingController();
    final topicFormKey = GlobalKey<FormState>();

    _textEngController.add(controllerE);
    _textVieController.add(controllerV);
    _formKeys.add(topicFormKey);
    _idWord.add("-1");
    word++;
  }

  void removeTextField(int index) {
    _textEngController.removeAt(index);
    _textVieController.removeAt(index);
    _formKeys.removeAt(index);
    if (widget.edit && _idWord[index] != "-1") {
      _idRemove.add(_idWord[index]);
    }
    _idWord.removeAt(index);
    word--;
  }

  void _pickFile() async {
    setState(() {
      _textEngController.clear();
      _textVieController.clear();
    });
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null || !result.files.first.name.endsWith('.csv')) return;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    filePath = result.files.first.path!;

    final input = File(filePath!).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    _textNameTopicController.text =
        result.files.first.name.replaceAll(".csv", "");
    if (fields[0][0] == 'Word' && fields[0][1] == 'Definition') {
      for (int i = 1; i < fields.length; i++) {
        TextEditingController controllerE = TextEditingController();
        TextEditingController controllerV = TextEditingController();
        final topicFormKey = GlobalKey<FormState>();
        word++;

        setState(() {
          controllerE.text = fields[i][0];
          controllerV.text = fields[i][1];
          _textEngController.add(controllerE);
          _textVieController.add(controllerV);
          _formKeys.add(topicFormKey);
          _idWord.add("-1");
        });
      }
    }
  }

  Future<void> loadForEdit(List<Word> listWord, Topic topic) async {
    setState(() {
      _textEngController.clear();
      _textVieController.clear();
      _textNameTopicController.text = topic.name;
      _textDesTopicController.text = topic.description;
    });
    for (Word pointer in listWord) {
      TextEditingController controllerE = TextEditingController();
      TextEditingController controllerV = TextEditingController();
      word++;
      final topicFormKey = GlobalKey<FormState>();
      setState(() {
        controllerE.text = pointer.english;
        controllerV.text = pointer.vietnamese;
        _textEngController.add(controllerE);
        _textVieController.add(controllerV);
        _idWord.add(pointer.id);
        _formKeys.add(topicFormKey);
      });
    }
  }

  // Handle click "Done" button"
  void handleClickDone(BuildContext context) async {
    var nameTopic = _textNameTopicController.text;
    var descriptionTopic = _textDesTopicController.text;

    if (word < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("The topic must have 4 words or more than")));
      return;
    }

    bool isValid = true;
    for (var _key in _formKeys) {
      if (!_key.currentState!.validate()) {
        isValid = false;
        break; // No need to continue if one of the fields is not valid
      }
    }

    if (!isValid) return;

    if (!_nameFormKey.currentState!.validate()) return;

    setState(() {
      isAdding = true;
    });

    var topic = Topic(
      id: widget.edit ? widget.topic!.id : const Uuid().v4(),
      name: nameTopic,
      idMaster: context.read<MyStore>().user.id,
      description: descriptionTopic,
      authorName: context.read<MyStore>().user.name,
      createdAt: DateTime.now(),
      isPublic: !isPrivate,
    );

    Future addTopicAndWords() async {
      try {
        await addTopic(topic);
        for (var i = 0; i < word; i++) {
          print("Folder: ${_idWord.length}");
          await addWordSByTopic(
            Word(
              id: (_idWord[i] == "-1") ? const Uuid().v4() : _idWord[i],
              english: _textEngController[i].text,
              vietnamese: _textVieController[i].text,
              idTopic: topic.id,
              status: "not learned",
              numberOfAnwserCorrect: 0,
            ),
          ).then((value) async {
            for (var i = 0; i < _idRemove.length; i++) {
              await deleteWordByID(_idRemove[i]);
            }
          });
        }

        await getFolderByID(context.read<MyStore>().user.folderID)
            .then((value) {
          value.topics.add(topic.id);
          return value;
        }).then((value) {
          updateFolder(value);
        });
      } catch (error) {
        print(error);
      }
    }

    try {
      if (imageFile != null) {
        imageName = "${const Uuid().v4()}_$imageName";
        topic.imageName = imageName;
        await FirebaseStorage.instance
            .ref("images/topics")
            .child(imageName)
            .putFile(imageFile!);
        await addTopicAndWords()
            .then((value) => null)
            .then((value) => Navigator.pop(context, topic));
      } else {
        if (widget.topic != null) {
          if (widget.topic!.imageName!.isNotEmpty) {
            topic.imageName = widget.topic!.imageName;
          }
        }
        await addTopicAndWords().then((value) => Navigator.pop(context, topic));
      }
    } catch (error) {
      print(error);
    }

    setState(() {
      isAdding = false;
    });
  }

  void _uploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        setState(() {
          imageFile = File(file.path!);
          imageName = file.name;
        });
      } else {}
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  void updateState(bool value) {
    isPrivate = value;
  }
}

class SwitchExample extends StatefulWidget {
  bool isPrivate;
  Function updateValue;
  SwitchExample(
      {super.key, required this.isPrivate, required this.updateValue});

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(
          Icons.check,
          color: Colors.green,
        );
      }
      return const Icon(Icons.close);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Switch(
          thumbIcon: thumbIcon,
          value: widget.isPrivate,
          activeColor: Colors.green,
          onChanged: (bool value) {
            setState(() {
              widget.isPrivate = value;
              widget.updateValue(value);
            });
          },
        ),
      ],
    );
  }
}
