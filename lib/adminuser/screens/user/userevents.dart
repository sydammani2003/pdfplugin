import 'package:flutter/material.dart';
import 'package:pdfplugin/adminuser/consts/colors.dart';
import 'package:pdfplugin/adminuser/screens/user/eventsdetails.dart';
import 'package:pdfplugin/adminuser/widgets/mntxt.dart';
import 'package:pdfplugin/screen/home_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenwidth = mediaquery.size.width;
    return Scaffold(
      backgroundColor: Usingcolors.bgcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (screenwidth <= 600) mobileview(context),
                if (screenwidth > 992) webview(context),
                if (screenwidth > 600 && screenwidth <= 992) tabview(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget mobileview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status bar simulation

        Mntxt(txt: 'Upcoming Events'),
        const SizedBox(height: 24),

        // Event Cards
        InkWell(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => EventDetailsScreen())),
          child: toshoweventcard(
            'Summer Music Festival 2024',
            'June 15, 2024',
            '7:00 PM',
          ),
        ),
        const SizedBox(height: 12),
        toshoweventcard(
          'Tech Conference 2024',
          'July 2, 2024',
          '9:00 AM',
        ),
        const SizedBox(height: 12),
        toshoweventcard(
          'Food & Wine Expo',
          'July 10, 2024',
          '11:00 AM',
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => PdfViewerHomeScreen()));
          },
          child: toshoweventcard(
            'Pdfs & Articles',
            '',
            '',
          ),
        ),
      ],
    );
  }

  Widget tabview(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              Mntxt(txt: 'Upcoming Events'),
              const SizedBox(height: 32),

              // Event Cards - Using InkWell for interactivity
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EventDetailsScreen()),
                ),
                child: toshoweventcard(
                  'Summer Music Festival 2024',
                  'June 15, 2024',
                  '7:00 PM',
                ),
              ),
              const SizedBox(height: 16),

              toshoweventcard(
                'Tech Conference 2024',
                'July 2, 2024',
                '9:00 AM',
              ),
              const SizedBox(height: 16),

              toshoweventcard(
                'Food & Wine Expo',
                'July 10, 2024',
                '11:00 AM',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget webview(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              Mntxt(txt: 'Upcoming Events'),
              const SizedBox(height: 32),

              // Event Cards
              InkWell(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => EventDetailsScreen())),
                child: toshoweventcard(
                  'Summer Music Festival 2024',
                  'June 15, 2024',
                  '7:00 PM',
                ),
              ),
              const SizedBox(height: 16),

              toshoweventcard(
                'Tech Conference 2024',
                'July 2, 2024',
                '9:00 AM',
              ),
              const SizedBox(height: 16),

              toshoweventcard(
                'Food & Wine Expo',
                'July 10, 2024',
                '11:00 AM',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget toshoweventcard(
      final String title, final String date, final String time) {
    return Container(
      decoration: BoxDecoration(
        color: Usingcolors.bgcolor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Usingcolors.mainhcolor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Usingcolors.btnbgcolor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$date • $time',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Usingcolors.btnbgcolor,
            ),
          ],
        ),
      ),
    );
  }
}
