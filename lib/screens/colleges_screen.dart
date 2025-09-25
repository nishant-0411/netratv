import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/college_service.dart';

class CollegeScreen extends StatefulWidget {
  const CollegeScreen({super.key});

  @override
  State<CollegeScreen> createState() => _CollegeScreenState();
}

class _CollegeScreenState extends State<CollegeScreen> with TickerProviderStateMixin {
  final CollegeService _collegeService = CollegeService();
  List<Map<String, dynamic>> _topColleges = [];
  List<Map<String, dynamic>> _nearbyColleges = [];
  bool _isLoading = true;
  String _interest = "";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCollegeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCollegeData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedInterest = prefs.getString('selected_interest') ?? "";
    
    if (savedInterest.isEmpty) {
      setState(() {
        _isLoading = false;
        _interest = "Unknown";
      });
      return;
    }
    
    _interest = savedInterest;
    
    // Load both top colleges and nearby colleges
    final topCollegesData = await _collegeService.getTopColleges(option: _interest);
    final nearbyCollegesData = await _collegeService.getTopCollegesNearYou();
    
    setState(() {
      _topColleges = List<Map<String, dynamic>>.from(topCollegesData["top_colleges"] ?? []);
      _nearbyColleges = List<Map<String, dynamic>>.from(nearbyCollegesData["top_colleges"] ?? []);
      _isLoading = false;
    });
  }

  Widget _buildCollegeCard(Map<String, dynamic> college) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: college["type"] == "government" ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    college["type"] ?? "N/A",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.school,
                  color: Colors.blue[600],
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              college["name"] ?? "Unknown College",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, college["address"] ?? "N/A"),
            _buildInfoRow(Icons.phone, college["phone"] ?? "N/A"),
            _buildInfoRow(Icons.language, college["website"] ?? "N/A"),
            _buildInfoRow(Icons.email, college["email"] ?? "N/A"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Entrance Exam: ${college["exam"] ?? "N/A"}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Admission: ${college["admission_info"] ?? "N/A"}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeList(List<Map<String, dynamic>> colleges, String emptyMessage) {
    if (colleges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: colleges.length,
      itemBuilder: (context, index) => _buildCollegeCard(colleges[index]),
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
                Material(
                  color: Colors.white,
                  elevation: 1,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.star),
                        text: 'Top Colleges',
                      ),
                      Tab(
                        icon: Icon(Icons.location_on),
                        text: 'Near You',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCollegeList(
                        _topColleges,
                        "No top colleges found for your interest: $_interest",
                      ),
                      _buildCollegeList(
                        _nearbyColleges,
                        "No colleges found in your area",
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
