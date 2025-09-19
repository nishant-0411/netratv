import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:developer';

class GoalsScreen extends StatefulWidget {
  final String? initialCareerChoice;

  const GoalsScreen({super.key, this.initialCareerChoice});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final List<Map<String, dynamic>> _todos = [];
  final TextEditingController _controller = TextEditingController();
  String _roadmap = "";
  bool _loadingRoadmap = false;

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _loadRoadmap();

    if (widget.initialCareerChoice != null) {
      _generateRoadmap(widget.initialCareerChoice!);
    }
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('goals_list');
    if (saved != null) {
      final List decoded = jsonDecode(saved);
      setState(() {
        _todos.addAll(decoded.map((e) => {
              'text': e['text'],
              'completed': e['completed'],
            }));
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('goals_list', jsonEncode(_todos));
  }

  Future<void> _loadRoadmap() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRoadmap = prefs.getString('last_roadmap');
    if (savedRoadmap != null) {
      setState(() => _roadmap = savedRoadmap);
    }
  }

  void _addTodo() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _todos.add({'text': _controller.text.trim(), 'completed': false});
        _controller.clear();
      });
      _saveTodos();
    }
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  void _toggleComplete(int index) {
    setState(() {
      _todos[index]['completed'] = !_todos[index]['completed'];
    });
    _saveTodos();
  }

  Future<void> _generateRoadmap(String career) async {
    setState(() {
      _loadingRoadmap = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final cachedKey = 'roadmap_$career'; // unique key per career
    final cachedRoadmap = prefs.getString(cachedKey);

    if (cachedRoadmap != null) {
      setState(() {
        _roadmap = cachedRoadmap;
        _loadingRoadmap = false;
      });
      return;
    }

    final prompt = """
# To Become a $career

**Step-by-step roadmap:**
1. Start with foundational education.
2. Gain practical experience and projects.
3. Build a portfolio and resume.
4. Apply for internships/jobs.
5. Continuous learning and upskilling.

**Recommended Resources:**
- [YouTube tutorials](https://www.youtube.com)
- [Online courses](https://www.coursera.org)
- [Books & References](https://www.amazon.com)
- Practical projects and exercises
""";

    try {
      final response = await Gemini.instance.prompt(
        parts: [Part.text(prompt)],
      );

      final result = response?.output ?? "No response from Gemini.";

      setState(() {
        _roadmap = result;
        _loadingRoadmap = false;
      });

      await prefs.setString(cachedKey, result);
    } catch (e) {
      log("❌ Error generating roadmap: $e");
      setState(() {
        _roadmap = "Failed to generate roadmap. Please try again.";
        _loadingRoadmap = false;
      });
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "To-Do"),
              Tab(text: "Roadmap & Resources"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter a goal',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addTodo,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _todos.isEmpty
                            ? const Center(
                                child: Text(
                                  'No goals added yet!',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            : Scrollbar(
                                thumbVisibility: true,
                                child: ListView.builder(
                                  itemCount: _todos.length,
                                  itemBuilder: (context, index) {
                                    final todo = _todos[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        child: Text('${index + 1}'),
                                      ),
                                      title: Text(
                                        todo['text'],
                                        style: TextStyle(
                                          decoration: todo['completed']
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: todo['completed'],
                                            onChanged: (_) =>
                                                _toggleComplete(index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _deleteTodo(index),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                _loadingRoadmap
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: MarkdownBody(
                          data: _roadmap,
                          selectable: true,
                          onTapLink: (text, href, title) {
                            if (href != null) _launchURL(href);
                          },
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
