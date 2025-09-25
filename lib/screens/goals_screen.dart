import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:netratv/services/roadmap_service.dart';
import 'package:netratv/services/scholarship_service.dart';
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
  // Scholarship state
  final TextEditingController _stateCtrl = TextEditingController();
  final TextEditingController _streamCtrl = TextEditingController();
  String _category = 'General';
  String _income = '3–8 LPA';
  String _level = 'Undergraduate';
  String _scholarshipResult = "";
  bool _loadingScholarships = false;

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
        _todos.addAll(
          decoded.map((e) => {'text': e['text'], 'completed': e['completed']}),
        );
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

    try {
      final service = RoadmapService();
      final result = await service.getRoadmap(career);

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
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "To-Do"),
              Tab(text: "Roadmaps"),
              Tab(text: "Scholarships"),
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
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
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
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () => _deleteTodo(index),
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
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Find Scholarships (India)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 380;
                          if (isNarrow) {
                            return Column(
                              children: [
                                TextField(
                                  controller: _stateCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'State / UT',
                                    hintText: 'e.g., Maharashtra',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _category,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'General',
                                      child: Text('General'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'OBC',
                                      child: Text('OBC'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'SC',
                                      child: Text('SC'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'ST',
                                      child: Text('ST'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'EWS',
                                      child: Text('EWS'),
                                    ),
                                  ],
                                  onChanged: (v) => setState(
                                    () => _category = v ?? 'General',
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Category',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _stateCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'State / UT',
                                    hintText: 'e.g., Maharashtra',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _category,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'General',
                                      child: Text('General'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'OBC',
                                      child: Text('OBC'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'SC',
                                      child: Text('SC'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'ST',
                                      child: Text('ST'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'EWS',
                                      child: Text('EWS'),
                                    ),
                                  ],
                                  onChanged: (v) => setState(
                                    () => _category = v ?? 'General',
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Category',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 380;
                          if (isNarrow) {
                            return Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _income,
                                  items: const [
                                    DropdownMenuItem(
                                      value: '<1 LPA',
                                      child: Text('<1 LPA'),
                                    ),
                                    DropdownMenuItem(
                                      value: '1–3 LPA',
                                      child: Text('1–3 LPA'),
                                    ),
                                    DropdownMenuItem(
                                      value: '3–8 LPA',
                                      child: Text('3–8 LPA'),
                                    ),
                                    DropdownMenuItem(
                                      value: '>8 LPA',
                                      child: Text('>8 LPA'),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _income = v ?? '3–8 LPA'),
                                  decoration: const InputDecoration(
                                    labelText: 'Family Income',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _level,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'School',
                                      child: Text('School'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Undergraduate',
                                      child: Text('Undergraduate'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Postgraduate',
                                      child: Text('Postgraduate'),
                                    ),
                                  ],
                                  onChanged: (v) => setState(
                                    () => _level = v ?? 'Undergraduate',
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Education Level',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _income,
                                  items: const [
                                    DropdownMenuItem(
                                      value: '<1 LPA',
                                      child: Text('<1 LPA'),
                                    ),
                                    DropdownMenuItem(
                                      value: '1–3 LPA',
                                      child: Text('1–3 LPA'),
                                    ),
                                    DropdownMenuItem(
                                      value: '3–8 LPA',
                                      child: Text('3–8 LPA'),
                                    ),
                                    DropdownMenuItem(
                                      value: '>8 LPA',
                                      child: Text('>8 LPA'),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _income = v ?? '3–8 LPA'),
                                  decoration: const InputDecoration(
                                    labelText: 'Family Income',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _level,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'School',
                                      child: Text('School'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Undergraduate',
                                      child: Text('Undergraduate'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Postgraduate',
                                      child: Text('Postgraduate'),
                                    ),
                                  ],
                                  onChanged: (v) => setState(
                                    () => _level = v ?? 'Undergraduate',
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Education Level',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _streamCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Stream / Discipline',
                          hintText: 'e.g., Engineering, Medicine, Arts',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _loadingScholarships
                              ? null
                              : () async {
                                  setState(() => _loadingScholarships = true);
                                  try {
                                    final svc = ScholarshipService();
                                    final result = await svc.getScholarships(
                                      state: _stateCtrl.text.trim().isEmpty
                                          ? 'All India'
                                          : _stateCtrl.text.trim(),
                                      category: _category,
                                      incomeBracket: _income,
                                      educationLevel: _level,
                                      stream: _streamCtrl.text.trim().isEmpty
                                          ? 'Any'
                                          : _streamCtrl.text.trim(),
                                    );
                                    setState(() => _scholarshipResult = result);
                                  } catch (_) {
                                    setState(
                                      () => _scholarshipResult =
                                          'Failed to fetch scholarships. Please try again.',
                                    );
                                  } finally {
                                    setState(
                                      () => _loadingScholarships = false,
                                    );
                                  }
                                },
                          icon: const Icon(Icons.search),
                          label: const Text('Find Scholarships'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _loadingScholarships
                          ? const Center(child: CircularProgressIndicator())
                          : (_scholarshipResult.isEmpty
                                ? const SizedBox.shrink()
                                : MarkdownBody(
                                    data: _scholarshipResult,
                                    selectable: true,
                                    onTapLink: (text, href, title) {
                                      if (href != null) _launchURL(href);
                                    },
                                  )),
                    ],
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
