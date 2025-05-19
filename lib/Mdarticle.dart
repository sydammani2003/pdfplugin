import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class Mdarticle extends StatelessWidget {
  final String markdownData = """
# Flutter Markdown Article

Welcome to the **Flutter Markdown Viewer** demo!

## ✨ Features
- Headers and formatting
- **Bold**, _Italic_, `Inline code`
- Lists with bullets or numbers
- [Flutter Website](https://flutter.dev)

> “Markdown is simple yet powerful.”

---

Enjoy writing in Markdown and rendering it beautifully in Flutter!
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Markdown Article')),
      body: Markdown(
        data: markdownData,
        padding: const EdgeInsets.all(16),
        onTapLink: (text, href, title) async {
          if (href != null && await canLaunchUrl(Uri.parse(href))) {
            await launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $href')),
            );
          }
        },
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: TextStyle(fontSize: 16),
          h1: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          h2: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
