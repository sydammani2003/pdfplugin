import 'package:flutter/material.dart';

class Txtiph extends StatelessWidget {
  final String txt;

  const Txtiph({super.key, required this.txt});

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    );
  }
}
