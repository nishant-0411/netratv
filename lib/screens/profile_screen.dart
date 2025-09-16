import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile photo
          const CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage("assets/profile.jpg"), 
          ),
          const SizedBox(height: 16),

          const Text(
            "John Doe",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          const Text(
            "Passionate Computer Science student, Flutter developer & AI enthusiast.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          const Divider(thickness: 1),

          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Courses I'm Doing:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                ListTile(
                  leading: Icon(Icons.book, color: Colors.blue),
                  title: Text("Data Structures & Algorithms"),
                ),
                ListTile(
                  leading: Icon(Icons.book, color: Colors.blue),
                  title: Text("Machine Learning Basics"),
                ),
                ListTile(
                  leading: Icon(Icons.book, color: Colors.blue),
                  title: Text("Mobile App Development with Flutter"),
                ),
              ],
            ),
          ),

          const Divider(thickness: 1),

          // Contact info
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.email, color: Colors.redAccent),
            title: Text("johndoe@email.com"),
          ),
          const ListTile(
            leading: Icon(Icons.phone, color: Colors.green),
            title: Text("+91 98765 43210"),
          ),
        ],
      ),
    );
  }
}
