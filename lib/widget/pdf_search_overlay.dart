// Widget for displaying search results overlay in PDF viewers
// Shows current match index and navigation controls

import 'package:flutter/material.dart';

class PdfSearchOverlay extends StatelessWidget {
  final int totalMatches;
  final int currentMatchIndex;
  final Function(int) onNavigate;

  const PdfSearchOverlay({
    super.key,
    required this.totalMatches,
    required this.currentMatchIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    if (totalMatches > 0) {
      return Positioned(
        top: 16,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${currentMatchIndex + 1} / $totalMatches',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Colors.white),
                  onPressed: totalMatches > 1
                      ? () => onNavigate(currentMatchIndex - 1)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, color: Colors.white),
                  onPressed: totalMatches > 1
                      ? () => onNavigate(currentMatchIndex + 1)
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}