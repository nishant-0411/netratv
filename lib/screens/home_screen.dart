import 'package:flutter/material.dart';
import 'goals_screen.dart';
import 'colleges_screen.dart';
import 'community_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? initialCareerChoice; 
  const HomeScreen({super.key, this.initialCareerChoice});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  final List<String> _titles = const [
    "Home",
    "Colleges For You",
    "Community",
    "Chatbot",
    "Profile",
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      GoalsScreen(initialCareerChoice: widget.initialCareerChoice),
      CollegeScreen(),
      CommunityScreen(
      interests: widget.initialCareerChoice != null
          ? [widget.initialCareerChoice!]
          : ['General'],
      ),
      ChatbotScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87, 
        elevation: 1,
      ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.school), label: "Colleges"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Community"),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chatbot"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
