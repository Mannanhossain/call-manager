import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // ADDED: Import HTTP package
import 'dart:convert'; // ADDED: For JSON encoding/decoding
import '../widgets/custom_textfield.dart';
import 'login_page.dart';
// import 'main_home_page.dart';

// Define the colors used in the design
const Color primaryTealDark = Color(0xFF00796B);
const Color primaryTealLight = Color(0xFF00BFA5);

// -------------------------------------------------------------------
// CUSTOM CLIPPER CLASSES (Used for the background design)
// -------------------------------------------------------------------

// Top organic, non-symmetrical wave clipper
class TopBlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.7);
    var firstControlPoint = Offset(size.width * 0.25, size.height * 1.1);
    var firstEndPoint = Offset(size.width * 0.6, size.height * 0.5);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 0.8, size.height * 0.1);
    var secondEndPoint = Offset(size.width, size.height * 0.2);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Bottom organic, non-symmetrical wave clipper
class BottomBlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height * 0.8);
    var firstControlPoint = Offset(size.width * 0.35, size.height * 0.2);
    var firstEndPoint = Offset(size.width * 0.8, size.height * 0.6);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 1.2, size.height * 1.1);
    var secondEndPoint = Offset(size.width, size.height);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// -------------------------------------------------------------------
// SIGNUP PAGE (Using HTTP for Registration)
// -------------------------------------------------------------------

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  // UPDATED: This function now uses the HTTP package for custom registration.
  void createAccount() async {
    // 1. Validate Passwords
    if (passwordController.text.trim() != confirmController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- Custom HTTP Registration Logic ---
    // !!! IMPORTANT: Replace this placeholder URL with your actual backend endpoint !!!
    const String apiUrl = 'https://your-custom-backend.com/api/register';

    try {
      // 2. Attempt to register the user via a POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          // Assuming your backend expects 'email' and 'password'
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      // 3. Check for successful response (typically 200 OK or 201 Created)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Account created successfully for ${emailController.text.trim()}! Please log in."),
              backgroundColor: primaryTealLight,
            ),
          );
        }

        // 4. CRITICAL STEP: Navigate to the Login Page upon success
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } else {
        // Handle server-side errors (4xx or 5xx)
        String errorMessage =
            'Registration failed (Status: ${response.statusCode}).';

        try {
          // Try to parse a detailed error message from the response body
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          }
        } catch (_) {
          // If JSON parsing fails, use the default status code message
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    } catch (e) {
      // Handle network errors (e.g., no internet connection, unreachable server)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Network error during registration: ${e.toString()}"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- DESIGN BLOBS ---
          // Top curved shape (Blob 1)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopBlobClipper(),
              child: Container(
                height: 300,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryTealDark, primaryTealLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // Bottom curved shape (Blob 2)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomBlobClipper(),
              child: Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryTealDark, primaryTealLight],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
          // --- END DESIGN BLOBS ---

          // Main content
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: primaryTealLight,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Join Wappblaster today",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Form Fields
                  CustomTextField(
                      controller: emailController,
                      hintText: "Email Address",
                      icon: Icons.email),
                  const SizedBox(height: 20),
                  CustomTextField(
                      controller: passwordController,
                      hintText: "Password",
                      icon: Icons.lock,
                      obscureText: true),
                  const SizedBox(height: 20),
                  CustomTextField(
                      controller: confirmController,
                      hintText: "Confirm Password",
                      icon: Icons.lock_outline,
                      obscureText: true),
                  const SizedBox(height: 40),

                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTealLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: createAccount,
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Already have account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          // Navigate back to Login Page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
