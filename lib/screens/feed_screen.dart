import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'profile_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';

class FeedScreen extends StatefulWidget {
  final String currentUserId;
  final String profileUserId; // Thêm profileUserId để truyền vào ProfileScreen

  const FeedScreen({super.key, required this.currentUserId, required this.profileUserId});

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
        // Truyền currentUserId vào HomeScreen nếu cần
        const HomeScreen(),

        // Truyền currentUserId vào SearchScreen
        SearchScreen(currentUserId: widget.currentUserId),

        const NotificationScreen(), // Không cần truyền currentUserId vào đây

        // Truyền currentUserId và profileUserId vào ProfileScreen
        ProfileScreen(currentUserId: widget.currentUserId, profileUserId: widget.profileUserId),
      ].elementAt(_selectedTab),
      
      bottomNavigationBar: CupertinoTabBar(
        onTap: (index) {
          setState(() {
            _selectedTab = index;
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
