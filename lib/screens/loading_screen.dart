import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String careerChoice;
  const LoadingScreen({super.key, required this.careerChoice});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  String _displayedText = "";
  int _charIndex = 0;
  late final String _fullText;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fullText = "Creating your personalised space...";
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.05).animate(_pulseController);
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });

    _startTyping();
    _simulateLoading();
  }

  void _startTyping() {
    Future.doWhile(() async {
      if (_charIndex < _fullText.length) {
        await Future.delayed(const Duration(milliseconds: 50));
        setState(() {
          _displayedText += _fullText[_charIndex];
          _charIndex++;
        });
        return true;
      } else {
        _pulseController.forward();
        return false;
      }
    });
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 6));
    _pulseController.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(initialCareerChoice: widget.careerChoice),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/loading.json',
              width: 220,
              height: 220,
              repeat: true,
            ),
            const SizedBox(height: 15), // Reduced gap
            ScaleTransition(
              scale: _pulseAnimation,
              child: Text(
                _displayedText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333), // Dark grey/blackish
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
