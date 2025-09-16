import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _currentNode = _buildQuiz();
  }

  QuestionNode _buildQuiz() {
    // Engineering streams
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

    // Medicine streams
    final medicineStreams = QuestionNode(
      question: "Which medical branch interests you?",
      options: [
        Option(text: "Surgeon"),
        Option(text: "Pediatrician"),
        Option(text: "Psychiatrist"),
        Option(text: "Cardiologist"),
      ],
    );

    // Commerce streams
    final commerceStreams = QuestionNode(
      question: "Which commerce path sounds good?",
      options: [
        Option(text: "Chartered Accountant"),
        Option(text: "Finance / Analyst"),
        Option(text: "Management (BBA/MBA)"),
        Option(text: "Economist"),
      ],
    );

    // Law streams
    final lawStreams = QuestionNode(
      question: "Which law branch attracts you?",
      options: [
        Option(text: "Corporate Law"),
        Option(text: "Criminal Law"),
        Option(text: "Civil Law"),
        Option(text: "International Law"),
      ],
    );

    // Computer Science streams
    final csStreams = QuestionNode(
      question: "Which CS specialization excites you?",
      options: [
        Option(text: "AI / ML"),
        Option(text: "Data Analytics"),
        Option(text: "Cybersecurity"),
        Option(text: "App Development"),
      ],
    );

    // Root question
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

  void _selectOption(Option option) {
    if (option.next != null) {
      setState(() {
        _currentNode = option.next!;
      });
    } else {
      // Last question → go to LoadingScreen
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
      appBar: AppBar(title: const Text("Career Quiz")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Question
              Text(
                _currentNode.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              // Options
              ..._currentNode.options.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () => _selectOption(option),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            option.text,
                            style: const TextStyle(fontSize: 18),
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
