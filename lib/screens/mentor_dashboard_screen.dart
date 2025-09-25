import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mentor_chat_screen.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> _myChatsStream(String mentorId) {
    return _firestore
        .collection('mentor_chats')
        .where('mentorId', isEqualTo: mentorId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view mentor dashboard'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _myChatsStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No doubts yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chatDoc = chats[index];
              final data = chatDoc.data();
              final lastMessage = (data['lastMessage'] ?? '') as String;
              final lastSender = (data['lastMessageSender'] ?? '') as String;
              final mentorName = (data['mentorName'] ?? 'Mentor') as String;
              final mentorId = (data['mentorId'] ?? '') as String;

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(lastSender.isNotEmpty ? lastSender : 'Student',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Open the chat; studentId is embedded in chat id
                    final chatId = chatDoc.id; // format: studentId_mentorId
                    final parts = chatId.split('_');
                    final studentId = parts.isNotEmpty ? parts.first : '';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MentorChatScreen(
                          mentorId: mentorId,
                          mentorName: mentorName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
