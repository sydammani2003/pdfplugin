
import 'package:flutter/material.dart';
import 'package:pdfplugin/adminuser/consts/colors.dart';

class Custombutton extends StatelessWidget {
  final String txt;
  final VoidCallback? call;
  final VoidCallback? calllong;
  const Custombutton({super.key, required this.txt, this.call, this.calllong});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: call,
      onLongPress: calllong,
      style: ElevatedButton.styleFrom(
        backgroundColor: Usingcolors.iconscolor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: Text(
        txt,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
