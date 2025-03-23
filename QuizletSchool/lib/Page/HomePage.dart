import 'package:curved_bottom_navigation/API/search.dart';
import 'package:curved_bottom_navigation/Post/SearchScreen.dart';
import 'package:curved_bottom_navigation/Screen/AddingScreen.dart';
import 'package:curved_bottom_navigation/Screen/ChallengeScreen.dart';
import 'package:curved_bottom_navigation/Screen/FolderScreen.dart';
import 'package:curved_bottom_navigation/Screen/HomeScreen.dart';
import 'package:curved_bottom_navigation/Screen/UserProfile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;
  final PageController _pageController = PageController();
  String searchValue = "";

  Future<List<String>> _fetchSuggestions(String searchValue) async {
    await Future.delayed(const Duration(milliseconds: 750));

    return getSuggestionString(searchValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EasySearchBar(
        backgroundColor: Colors.black,
        title: const Text(
          'QuizletSchool',
          style: TextStyle(
            color: Colors.green,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        onSearch: (value) => (searchValue = value),
        onSuggestionTap: (data) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(
                searchWord: data,
              ),
            ),
          );
        },
        asyncSuggestions: (value) async => await _fetchSuggestions(value),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      body: PageView(
        controller: _pageController,
        children: const <Widget>[
          HomeScreen(),
          ChallengeScreen(),
          AddingScreen(),
          FolderScreen(),
          UserProfile(),
        ],
        onPageChanged: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return CurvedNavigationBar(
      backgroundColor: Colors.black,
      buttonBackgroundColor: Colors.green,
      color: Colors.green,
      index: _page,
      animationDuration: const Duration(milliseconds: 200),
      onTap: (index) {
        setState(() {
          _page = index;
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        });
      },
      items: const <Widget>[
        Icon(Icons.home, size: 26, color: Colors.black),
        Icon(Icons.bar_chart, size: 26, color: Colors.black),
        Icon(Icons.add, size: 26, color: Colors.black),
        Icon(Icons.folder, size: 26, color: Colors.black),
        Icon(Icons.person, size: 26, color: Colors.black),
      ],
    );
  }
}
