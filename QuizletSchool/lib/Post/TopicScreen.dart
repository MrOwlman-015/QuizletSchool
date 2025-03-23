import 'package:curved_bottom_navigation/API/folder.dart';
import 'package:curved_bottom_navigation/Class/Folder.dart';
import 'package:curved_bottom_navigation/Class/Topic.dart';
import 'package:curved_bottom_navigation/Class/User.dart';
import 'package:curved_bottom_navigation/Post/FlashCard.dart';
import 'package:curved_bottom_navigation/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key, required this.idFolder});
  final String idFolder;

  @override
  State<TopicScreen> createState() => _TopicScreenState(idFolder: idFolder);
}

class _TopicScreenState extends State<TopicScreen> {
  _TopicScreenState({required this.idFolder});
  final String idFolder;
  List<Topic> name = []; //tên topic
  @override
  Widget build(BuildContext context) {
    Users user = context.read<MyStore>().user;
    return FutureBuilder(
      future: (idFolder != user.bookMarkFolder)
          ? getFolderByID(idFolder)
          : getBookmarkTopic(user),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error in loading folder: ${snapshot.error}"),
          );
        }

        if (snapshot.hasData) {
          Folder folder = snapshot.data!;

          name = folder.detailTopic;

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: (idFolder != user.bookMarkFolder) //id folder bookmark
                ? AppBar(
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    title: Text(
                      folder.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    leading: IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  )
                : null,
            body: GridView.builder(
              itemBuilder: (context, index) {
                return _buildTopicItem(context, index);
              },
              itemCount: folder.detailTopic.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.8),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildTopicItem(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FlashCard(topic: name[index], isPushed: true),
              ));
        },
        child: Stack(
          children: [
            Image.network(
              "https://i.ytimg.com/vi/xorYi2I-FLk/maxresdefault.jpg",
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.3,
              fit: BoxFit.fitHeight,
            ),
            Container(
                alignment: Alignment.center,
                color: Colors.black.withOpacity(0.4),
                child: Text(
                  name[index].name,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )),
          ],
        ),
      ),
    );
  }
}
