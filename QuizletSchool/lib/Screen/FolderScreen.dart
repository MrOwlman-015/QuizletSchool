import 'package:curved_bottom_navigation/Post/TopicScreen.dart';
import 'package:curved_bottom_navigation/Post/VocabFavorite.dart';
import 'package:curved_bottom_navigation/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Class/User.dart';
import '../Post/Folder.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => FolderScreenState();
}

class FolderScreenState extends State<FolderScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const TabBarExample();
  }
}

class TabBarExample extends StatelessWidget {
  const TabBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    Users user = context.read<MyStore>().user;
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("Welcome ${user.name}"),
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          backgroundColor: Colors.black,
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.folder),
              ),
              Tab(
                icon: Icon(Icons.star),
              ),
              Tab(
                icon: Icon(Icons.bookmark),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: ListViewFolder(idFolder: context.read<MyStore>().user. folderID,isPush: false),
            ),
            const Center(
              child: VocabFavourite(),
            ), 
            Center(
              child: TopicScreen(
                  idFolder: context.read<MyStore>().user.bookMarkFolder),
            ),
          ],
        ),
      ),
    );
  }
}
