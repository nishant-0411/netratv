import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String gender = '';
  String verificationId = '';
  bool otpSent = false;
  bool isLoading = false;

  // Animation flags for form and OTP separately
  bool animationPlayedForm = false;
  bool animationPlayedOtp = false;

  bool _validateInputs() {
    final name = nameController.text.trim();
    final age = ageController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || age.isEmpty || phone.isEmpty || email.isEmpty || gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return false;
    }
    if (int.tryParse(age) == null || int.parse(age) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age')),
      );
      return false;
    }
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return false;
    }
    return true;
  }

  Future<void> _sendOtp() async {
    if (!_validateInputs()) return;

    setState(() => isLoading = true);

    final phoneNumber = '+91${phoneController.text.trim()}';

    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        otpSent = true;
        isLoading = false;
        animationPlayedOtp = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _onSignupSuccess();
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Verification failed')),
          );
          setState(() => isLoading = false);
        },
        codeSent: (String verId, int? resendToken) {
          setState(() {
            verificationId = verId;
            otpSent = true;
            isLoading = false;
            animationPlayedOtp = false; // Reset OTP animation
          });
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 700));
      _onSignupSuccess();
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // OTP verified successfully, show a short loading then navigate
      await Future.delayed(const Duration(milliseconds: 500));
      _onSignupSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Invalid OTP')),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP: $e')),
      );
    }
  }

  Future<void> _onSignupSuccess() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': nameController.text.trim(),
        'age': int.parse(ageController.text.trim()),
        'gender': gender,
        'phone': user.phoneNumber,
        'email': emailController.text.trim(),
        'bio': 'Excited to learn new things!',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // Navigate without showing OTP again
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/prequiz', (route) => false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.blueAccent)
              : otpSent
                  ? _buildOtpView()
                  : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedTextKit(
            isRepeatingAnimation: false,
            animatedTexts: [
              TypewriterAnimatedText(
                'Sign up with your details',
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                speed: const Duration(milliseconds: 50),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.black),
            decoration: _inputDecoration('Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.black),
            decoration: _inputDecoration('Age'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: gender.isEmpty ? null : gender,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black, fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            hint: const Text(
              'Select Gender',
              style: TextStyle(color: Colors.black54),
            ),
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => gender = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.black),
            decoration: _inputDecoration('Phone Number'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.black),
            decoration: _inputDecoration('Email'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _sendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedTextKit(
          isRepeatingAnimation: false,
          animatedTexts: [
            TypewriterAnimatedText(
              'Enter the OTP sent on your phone',
              textStyle: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              speed: const Duration(milliseconds: 50),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.black),
          decoration: _inputDecoration('OTP'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Verify OTP'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: Colors.black12,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
