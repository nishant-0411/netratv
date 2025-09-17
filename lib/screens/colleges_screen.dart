import 'package:flutter/material.dart';
import '../services/college_service.dart';

class CollegeScreen extends StatefulWidget {
  final String interest;
  const CollegeScreen({super.key, required this.interest});

  @override
  State<CollegeScreen> createState() => _CollegeScreenState();
}

class _CollegeScreenState extends State<CollegeScreen> {
  final CollegeService _collegeService = CollegeService();
  List<Map<String, dynamic>> _colleges = [];
  bool _isLoading = true;
  String _source = "";

  @override
  void initState() {
    super.initState();
    _loadColleges();
  }

  Future<void> _loadColleges() async {
    final data = await _collegeService.getTopColleges(option: widget.interest);
    setState(() {
      _colleges = List<Map<String, dynamic>>.from(data["top_colleges"] ?? []);
      _source = data["source"] ?? "";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Top Colleges - ${widget.interest}"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _colleges.isEmpty
              ? const Center(child: Text("No colleges found."))
              : ListView.builder(
                  itemCount: _colleges.length,
                  itemBuilder: (context, index) {
                    final college = _colleges[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        title: Text(college["name"] ?? "Unknown"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("📍 ${college["address"] ?? "N/A"}"),
                            Text("☎️ ${college["phone"] ?? "N/A"}"),
                            Text("🌐 ${college["website"] ?? "N/A"}"),
                            Text("📧 ${college["email"] ?? "N/A"}"),
                            Text("Exam: ${college["exam"] ?? "N/A"}"),
                            Text("Admission: ${college["admission_info"] ?? "N/A"}"),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
      bottomNavigationBar: _source.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Source: $_source",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          : null,
    );
  }
}
