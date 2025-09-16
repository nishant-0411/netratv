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
  String? _finalChoice;

  @override
  void initState() {
    super.initState();
    _currentNode = _buildQuiz();
  }

  QuestionNode _buildQuiz() {
    final engineering = QuestionNode(
      question: "Which engineering field excites you?",
      options: [
        Option(text: "AI / ML"),
        Option(text: "Data Science"),
        Option(text: "Mechanical"),
        Option(text: "Civil"),
      ],
    );

    final medicine = QuestionNode(
      question: "Which medical branch interests you?",
      options: [
        Option(text: "Surgeon"),
        Option(text: "Pediatrician"),
        Option(text: "Psychiatrist"),
      ],
    );

    final commerce = QuestionNode(
      question: "Which commerce path sounds good?",
      options: [
        Option(text: "Chartered Accountant"),
        Option(text: "Finance / Analyst"),
        Option(text: "Management (BBA/MBA)"),
      ],
    );

    final law = QuestionNode(
      question: "Which law branch attracts you?",
      options: [
        Option(text: "Corporate Law"),
        Option(text: "Criminal Law"),
        Option(text: "Civil Law"),
      ],
    );

    // Root
    return QuestionNode(
      question: "Which subject do you find cool and easy?",
      options: [
        Option(text: "Science", next: medicine),
        Option(text: "Math", next: engineering),
        Option(text: "Commerce", next: commerce),
        Option(text: "Arts", next: law),
        Option(text: "Computer Science", next: engineering),
      ],
    );
  }

  void _selectOption(Option option) {
    if (option.next != null) {
      setState(() {
        _currentNode = option.next!;
      });
    } else {
      _finalChoice = option.text;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoadingScreen(careerChoice: _finalChoice!),
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
              Text(
                _currentNode.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
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
