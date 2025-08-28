import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../api_key.dart';
import '../provider/text_gears_provider.dart';
import '../views/homepage.dart';

void main() {
  runApp(const WriteRight());
}

class WriteRight extends StatelessWidget {
  const WriteRight({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TextGearsProvider(apiKey: apiKey),
      child: MaterialApp(
        title: 'Write Right',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(textTheme: GoogleFonts.latoTextTheme()),
        home: Homepage(),
      ),
    );
  }
}
