import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'mentor_chat_screen.dart';
import 'mentor_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MentorsScreen extends StatelessWidget {
  const MentorsScreen({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _mentorStream() {
    return FirebaseFirestore.instance
        .collection('mentors')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  void _openMentorChat(BuildContext context, String mentorId, String mentorName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MentorChatScreen(
          mentorId: mentorId,
          mentorName: mentorName,
        ),
      ),
    );
  }

  Future<void> _seedDummyMentors(BuildContext context) async {
    final dummyMentors = [
      {
        'name': 'Dr. Meera Sharma',
        'bio': 'Cardiologist with 10+ years mentoring pre-med students.',
        'expertise': ['medical', 'NEET-UG', 'Biology'],
        'experienceYears': 12,
      },
      {
        'name': 'Arjun Patel',
        'bio': 'Software Engineer specializing in AI/ML and Data Science.',
        'expertise': ['engineering', 'AI / ML', 'Data Science'],
        'experienceYears': 7,
      },
      {
        'name': 'Niharika Rao',
        'bio': 'Civil engineer guiding students for JEE and college choices.',
        'expertise': ['engineering', 'Civil', 'JEE'],
        'experienceYears': 9,
      },
      {
        'name': 'Raghav Gupta',
        'bio': 'Finance professional mentoring CA/Commerce aspirants.',
        'expertise': ['commerce', 'Chartered Accountant', 'Finance Analyst'],
        'experienceYears': 8,
      },
      {
        'name': 'Ananya Iyer',
        'bio': 'Law graduate mentoring CLAT aspirants with practical tips.',
        'expertise': ['law', 'CLAT', 'AILET'],
        'experienceYears': 6,
      },
    ];

    final batch = FirebaseFirestore.instance.batch();
    final col = FirebaseFirestore.instance.collection('mentors');
    for (final m in dummyMentors) {
      final doc = col.doc();
      batch.set(doc, {
        ...m,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Dummy mentors seeded')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _mentorStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
              actions: [
                IconButton(
                  tooltip: 'Dashboard',
                  icon: const Icon(Icons.dashboard_customize_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MentorDashboardScreen(),
                    ),
                  ),
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No mentors available yet'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _seedDummyMentors(context),
                    icon: const Icon(Icons.auto_fix_high_outlined),
                    label: const Text('Add Sample Mentors'),
                  ),
                ],
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Clear Your Doubts Here'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
            actions: [
              IconButton(
                tooltip: 'Dashboard',
                icon: const Icon(Icons.dashboard_customize_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MentorDashboardScreen(),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Seed Mentors',
                icon: const Icon(Icons.auto_fix_high_outlined),
                onPressed: () => _seedDummyMentors(context),
              ),
            ],
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final mentorId = doc.id;
              final name = data['name'] ?? 'Mentor';
              final bio = (data['bio'] ?? '') as String;
              final expertise =
                  (data['expertise'] as List?)?.cast<String>() ??
                  const <String>[];
              final experienceYears = (data['experienceYears'] ?? 0) as int;

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(child: Icon(Icons.person)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '$experienceYears yrs experience',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _openMentorChat(context, mentorId, name),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(bio),
                      ],
                      if (expertise.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: expertise
                              .map((e) => Chip(label: Text(e)))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
