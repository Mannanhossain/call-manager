import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/custom_textfield.dart';
import 'signup_page.dart';
import 'main_home_page.dart';

// Define the colors used in the design
const Color primaryTealDark = Color(0xFF00796B);
const Color primaryTealLight = Color(0xFF00BFA5);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Placeholder URL for custom API - REPLACE THIS WITH YOUR REAL API ENDPOINT
  static const String _loginApiUrl = 'https://api.example.com/auth/login';

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Login Logic using HTTP POST ---
  void _login() async {
    // 1. Input validation
    if (_phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter both email/phone and password."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final String emailOrPhone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      // 2. Send HTTP POST request
      final response = await http.post(
        Uri.parse(_loginApiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // The body structure depends on your backend (e.g., 'email' or 'username')
        body: jsonEncode(<String, String>{
          'email_or_phone': emailOrPhone,
          'password': password,
        }),
      );

      // 3. Handle response status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        // SUCCESS: Parse and process the token/user data
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? token = responseData['token'];

        // In a real application, save the token to secure storage here.
        debugPrint('Login successful. Token: $token');

        // Navigate to the HomePage
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Successful!"),
              backgroundColor: primaryTealLight,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        // FAILURE: Handle error status codes
        String errorMessage = "Login failed. Status: ${response.statusCode}";
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          // Attempt to extract a specific message from the API response
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {
          // Fallback for non-JSON or unexpected error body
          errorMessage =
              'Login failed with status ${response.statusCode}. Check server status.';
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
      // 4. Handle Network Errors (e.g., connection timed out, host unreachable)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Network or Server connection failed: ${e.toString()}"),
            backgroundColor: Colors.deepOrange,
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

          // Main content
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Logo (Chat Bubble Icon)
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
                    "Hello",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sign in to your account",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Phone/Email field (Using imported CustomTextField)
                  CustomTextField(
                    controller: _phoneController,
                    hintText: "Phone / Email",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  // Password field (Using imported CustomTextField)
                  CustomTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Action for Forgot password
                        // In a real app, this would navigate to a password reset screen
                      },
                      child: const Text(
                        "Forgot your password?",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Login Button
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
                      onPressed: _login, // Calls the HTTP Login logic
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Create account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don’t have an account? "),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Signup Page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Create",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),

                  const Text(
                    "Preconet Technologies",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
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

// -------------------------------------------------------------------
// CUSTOM CLIPPER CLASSES FOR THE ORGANIC BACKGROUND DESIGN (Copied from original)
// -------------------------------------------------------------------

// Top organic, non-symmetrical wave clipper
class TopBlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.7);

    // First curve (simulating the overlapping look)
    var firstControlPoint = Offset(size.width * 0.25, size.height * 1.1);
    var firstEndPoint = Offset(size.width * 0.6, size.height * 0.5);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    // Second curve (continuing to the top right)
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

    // First curve (simulating the curve upwards)
    var firstControlPoint = Offset(size.width * 0.35, size.height * 0.2);
    var firstEndPoint = Offset(size.width * 0.8, size.height * 0.6);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    // Second curve (completing the shape downwards)
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
