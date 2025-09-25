import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'signup_role_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool showQuestion = false;
  bool showOptions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: showQuestion
                    ? Text(
                        "Do you already have an account?",
                        key: const ValueKey('question'),
                        style: const TextStyle(
                          color: Colors.black87, // changed text color to dark
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : SizedBox(
                        key: const ValueKey('welcomeText'),
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 28.0,
                            color: Colors.black, // changed text color to black
                            fontWeight: FontWeight.bold,
                          ),
                          child: AnimatedTextKit(
                            totalRepeatCount: 1,
                            animatedTexts: [
                              TypewriterAnimatedText(
                                "👋 Welcome to Netratv!",
                                speed: const Duration(milliseconds: 100),
                              ),
                            ],
                            onFinished: () {
                              setState(() => showQuestion = true);
                              Future.delayed(const Duration(seconds: 1), () {
                                setState(() => showOptions = true);
                              });
                            },
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              AnimatedOpacity(
                opacity: showOptions ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: showOptions
                    ? Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Yes, Login"),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SignupRoleScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("No, Sign Up"),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
