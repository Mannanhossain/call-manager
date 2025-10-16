import 'package:flutter/material.dart';
import 'pages/splash_page.dart';

void main() {
  runApp(const AutoSmsApp());
}

class AutoSmsApp extends StatelessWidget {
  const AutoSmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Preconet Technology',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SplashPage(),
    );
  }
}
