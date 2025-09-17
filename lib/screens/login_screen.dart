import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String verificationId = "";
  bool otpSent = false;
  bool isLoading = false;

Future<void> _sendOtp() async {
setState(() => isLoading = true);

  if (kIsWeb) {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      otpSent = true;
      isLoading = false;
    });
  } else {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91${phoneController.text.trim()}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "Verification failed")),
          );
          setState(() => isLoading = false);
        },
        codeSent: (String verId, int? resendToken) {
          setState(() {
            verificationId = verId;
            otpSent = true;
            isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send OTP: $e")),
      );
      setState(() => isLoading = false);
    }
  }
}


  Future<void> _verifyOtp() async {
  setState(() => isLoading = true);

  if (kIsWeb) {
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);

    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    
    // Or if you want to clear the stack completely:
    // Navigator.pushNamedAndRemoveUntil(context, '/quiz', (route) => false);
  } else {
    // Real mobile Firebase OTP logic
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP")),
      );
    }
  }

  setState(() => isLoading = false);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          '👋 Welcome!',
                          textStyle: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                        TypewriterAnimatedText(
                          otpSent
                              ? 'Enter the OTP sent to your phone'
                              : 'Please enter your phone number',
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                          speed: const Duration(milliseconds: 80),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: otpSent ? otpController : phoneController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          otpSent ? Icons.lock : Icons.phone,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        hintText: otpSent ? "Enter OTP" : "Phone Number",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: otpSent ? _verifyOtp : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: Text(otpSent ? "Verify OTP" : "Continue"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();

//   String verificationId = "";
//   bool otpSent = false;
//   bool isLoading = false;

//   Future<void> _sendOtp() async {
//     setState(() => isLoading = true);

//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: "+91${phoneController.text.trim()}",
//       timeout: const Duration(seconds: 60),
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         // Auto sign in if OTP auto-retrieved
//         await FirebaseAuth.instance.signInWithCredential(credential);
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.message ?? "Verification failed")),
//         );
//         setState(() => isLoading = false);
//       },
//       codeSent: (String verId, int? resendToken) {
//         setState(() {
//           verificationId = verId;
//           otpSent = true;
//           isLoading = false;
//         });
//       },
//       codeAutoRetrievalTimeout: (String verId) {
//         verificationId = verId;
//       },
//     );
//   }

//   Future<void> _verifyOtp() async {
//     setState(() => isLoading = true);

//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: otpController.text.trim(),
//       );

//       await FirebaseAuth.instance.signInWithCredential(credential);
//       // AuthWrapper will handle navigation to QuizScreen automatically
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Invalid OTP")),
//       );
//     }

//     setState(() => isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: isLoading
//               ? const CircularProgressIndicator(color: Colors.white)
//               : Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               AnimatedTextKit(
//                 animatedTexts: [
//                   TypewriterAnimatedText(
//                     '👋 Welcome!',
//                     textStyle: const TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                     speed: const Duration(milliseconds: 100),
//                   ),
//                   TypewriterAnimatedText(
//                     otpSent
//                         ? 'Enter the OTP sent to your phone'
//                         : 'Please enter your phone number',
//                     textStyle: const TextStyle(
//                       fontSize: 20,
//                       color: Colors.white70,
//                     ),
//                     speed: const Duration(milliseconds: 80),
//                   ),
//                 ],
//                 totalRepeatCount: 1,
//               ),
//               const SizedBox(height: 40),
//               TextField(
//                 controller: otpSent ? otpController : phoneController,
//                 style: const TextStyle(color: Colors.white),
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(
//                     otpSent ? Icons.lock : Icons.phone,
//                     color: Colors.white70,
//                   ),
//                   hintText: otpSent ? "Enter OTP" : "Phone Number",
//                   hintStyle: const TextStyle(color: Colors.white54),
//                   filled: true,
//                   fillColor: Colors.white10,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: otpSent ? _verifyOtp : _sendOtp,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 50, vertical: 15),
//                 ),
//                 child: Text(otpSent ? "Verify OTP" : "Continue"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
