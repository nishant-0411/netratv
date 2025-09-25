import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_group_chat_screen.dart';

class CommunityScreen extends StatefulWidget {
  final List<String> interests;

  const CommunityScreen({super.key, required this.interests});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCommunityGroups();
  }

  Future<void> _initializeCommunityGroups() async {
    // Initialize default community groups if they don't exist
    final defaultGroups = [
      {
        'id': 'general_discussion',
        'name': 'General Discussion',
        'description': 'General chat for all students',
        'category': 'General',
        'icon': Icons.chat,
        'color': Colors.blue,
      },
      {
        'id': 'study_help',
        'name': 'Study Help',
        'description': 'Ask and answer study-related questions',
        'category': 'Academic',
        'icon': Icons.school,
        'color': Colors.green,
      },
      {
        'id': 'career_guidance',
        'name': 'Career Guidance',
        'description': 'Discuss career paths and opportunities',
        'category': 'Career',
        'icon': Icons.work,
        'color': Colors.orange,
      },
      {
        'id': 'exam_preparation',
        'name': 'Exam Preparation',
        'description': 'Share tips and resources for exam prep',
        'category': 'Academic',
        'icon': Icons.quiz,
        'color': Colors.purple,
      },
      {
        'id': 'college_admissions',
        'name': 'College Admissions',
        'description': 'Discuss college applications and admissions',
        'category': 'Academic',
        'icon': Icons.school,
        'color': Colors.red,
      },
      {
        'id': 'tech_discussions',
        'name': 'Tech Discussions',
        'description': 'Technology and programming discussions',
        'category': 'Technology',
        'icon': Icons.computer,
        'color': Colors.indigo,
      },
    ];

    try {
      for (final group in defaultGroups) {
        await _firestore.collection('community_groups').doc(group['id'] as String).set({
          'name': group['name'],
          'description': group['description'],
          'category': group['category'],
          'createdAt': FieldValue.serverTimestamp(),
          'memberCount': 0,
          'lastMessage': '',
          'lastMessageTime': null,
          'lastMessageSender': '',
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error initializing groups: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _joinGroup(String groupId, String groupName, String groupDescription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityGroupChatScreen(
          groupId: groupId,
          groupName: groupName,
          groupDescription: groupDescription,
        ),
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> groupData, String groupId) {
    final name = groupData['name'] ?? 'Unknown Group';
    final description = groupData['description'] ?? 'No description';
    final category = groupData['category'] ?? 'General';
    final memberCount = groupData['memberCount'] ?? 0;
    final lastMessage = groupData['lastMessage'] ?? '';
    final lastMessageSender = groupData['lastMessageSender'] ?? '';

    // Get color based on category
    Color categoryColor;
    IconData categoryIcon;
    
    switch (category) {
      case 'Academic':
        categoryColor = Colors.green;
        categoryIcon = Icons.school;
        break;
      case 'Career':
        categoryColor = Colors.orange;
        categoryIcon = Icons.work;
        break;
      case 'Technology':
        categoryColor = Colors.indigo;
        categoryIcon = Icons.computer;
        break;
      default:
        categoryColor = Colors.blue;
        categoryIcon = Icons.chat;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _joinGroup(groupId, name, description),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          memberCount.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              if (lastMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          lastMessageSender.isNotEmpty 
                              ? '$lastMessageSender: $lastMessage'
                              : lastMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.group, color: Colors.blue[600], size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Student Communities',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join groups to connect with fellow students, ask questions, and share knowledge!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('community_groups')
                        .orderBy('category')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No community groups available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final groups = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          final groupData = group.data() as Map<String, dynamic>;
                          return _buildGroupCard(groupData, group.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
