import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../views/homepage.dart';

void main() {
  runApp(const WriteRight());
}

class WriteRight extends StatelessWidget {
  const WriteRight({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Write Right',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      home: Homepage(),
    );
  }
}
