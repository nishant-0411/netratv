import 'package:flutter/material.dart';
import 'goals_screen.dart';
import 'colleges_screen.dart';
import 'community_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? initialCareerChoice; // receives careerChoice from LoadingScreen

  const HomeScreen({super.key, this.initialCareerChoice});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  final List<String> _titles = const [
    "Home",
    "Colleges Near You",
    "Community",
    "Chatbot",
    "Profile",
  ];

  @override
  void initState() {
    super.initState();

    // Pass careerChoice to GoalsScreen dynamically
    _screens = [
      GoalsScreen(initialCareerChoice: widget.initialCareerChoice),
      CollegeScreen(),
      CommunityScreen(),
      ChatbotScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // disable Android back button
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_selectedIndex]),
          automaticallyImplyLeading: false, // remove back button
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
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
