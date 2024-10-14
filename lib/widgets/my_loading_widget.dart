import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyLoadingWidget extends StatelessWidget {
  final String text;

  const MyLoadingWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(
            height: 10,
          ),
          Text(
            text,
            style: GoogleFonts.robotoMono(),
          )
        ],
      ),
    );
  }
}
