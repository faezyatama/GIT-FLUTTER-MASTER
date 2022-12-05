import 'package:flutter/material.dart';

import 'chatLiveSupport.dart';
import 'chatpage.dart';

class ChatApp extends StatefulWidget {
  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  //BOTTOM NAVIGATION BAR
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        _selectedIndex = index;
      } else if (index == 1) {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_selectedIndex == 0)
          ? ChatPage()
          : LiveSupportChatDetailPage(), //LiveSupport(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Live Support",
          ),
        ],
      ),
    );
  }
}
