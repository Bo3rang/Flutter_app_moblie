import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'profile_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';

class FeedScreen extends StatefulWidget {
  
  final String currentUserId;
  const FeedScreen({super.key, required this.currentUserId});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: [
        const HomeScreen(),
        const SearchScreen(),
        const NotificationScreen(),
        // Truyền currentUserId vào ProfileScreen
        ProfileScreen(currentUserId: widget.currentUserId),
      ].elementAt(_selectedTab),
      bottomNavigationBar: CupertinoTabBar(
        onTap: (Index){
          setState(() {
            _selectedTab = Index;
          });
        }, 
        activeColor: Colors.blue[400],
        currentIndex: _selectedTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.accessibility)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),  
        ],
      ),
    );
  }
}
