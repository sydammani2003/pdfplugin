
import 'package:flutter/material.dart';
import 'package:pdfplugin/adminuser/consts/colors.dart';

class Mntxt extends StatelessWidget {
  final String txt;
  const Mntxt({super.key,required this.txt});

  @override
  Widget build(BuildContext context) {
    return Text(
                    txt,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Usingcolors.mainhcolor,
                    ),
                  );
  }
}
