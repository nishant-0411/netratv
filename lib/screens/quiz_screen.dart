import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loading_screen.dart';

class QuestionNode {
  final String question;
  final List<Option> options;

  QuestionNode({required this.question, required this.options});
}

class Option {
  final String text;
  final QuestionNode? next;

  Option({required this.text, this.next});
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuestionNode _currentNode;
  List<String> selectedInterests = [];

  @override
  void initState() {
    super.initState();
    _currentNode = _buildQuiz();
  }

  QuestionNode _buildQuiz() {
    final engineeringStreams = QuestionNode(
      question: "Which engineering field excites you?",
      options: [
        Option(text: "AI / ML"),
        Option(text: "Data Science"),
        Option(text: "Mechanical"),
        Option(text: "Civil"),
        Option(text: "Electrical"),
      ],
    );

    final medicineStreams = QuestionNode(
      question: "Which medical branch interests you?",
      options: [
        Option(text: "Surgeon"),
        Option(text: "Pediatrician"),
        Option(text: "Psychiatrist"),
        Option(text: "Cardiologist"),
      ],
    );

    final commerceStreams = QuestionNode(
      question: "Which commerce path sounds good?",
      options: [
        Option(text: "Chartered Accountant"),
        Option(text: "Finance / Analyst"),
        Option(text: "Management (BBA/MBA)"),
        Option(text: "Economist"),
      ],
    );

    final lawStreams = QuestionNode(
      question: "Which law branch attracts you?",
      options: [
        Option(text: "Corporate Law"),
        Option(text: "Criminal Law"),
        Option(text: "Civil Law"),
        Option(text: "International Law"),
      ],
    );

    final csStreams = QuestionNode(
      question: "Which CS specialization excites you?",
      options: [
        Option(text: "AI / ML"),
        Option(text: "Data Analytics"),
        Option(text: "Cybersecurity"),
        Option(text: "App Development"),
      ],
    );

    return QuestionNode(
      question: "Which subject do you find cool and easy?",
      options: [
        Option(text: "Science", next: medicineStreams),
        Option(text: "Math", next: engineeringStreams),
        Option(text: "Commerce", next: commerceStreams),
        Option(text: "Arts", next: lawStreams),
        Option(text: "Computer Science", next: csStreams),
      ],
    );
  }

  void _selectOption(Option option) async {
    selectedInterests.add(option.text);

    if (option.next != null) {
      setState(() {
        _currentNode = option.next!;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_interest', option.text);
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'interests': selectedInterests}, SetOptions(merge: true));
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoadingScreen(careerChoice: option.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ White background
      appBar: AppBar(
        title: const Text("Career Quiz"),
        backgroundColor: Colors.blueAccent, // optional, gives a modern feel
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentNode.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              ..._currentNode.options.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    splashColor: Colors.blue.withOpacity(0.2),
                    onTap: () => _selectOption(option),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // purple-blue gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 16),
                        child: Center(
                          child: Text(
                            option.text,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white, // text visible on gradient
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
}
}
