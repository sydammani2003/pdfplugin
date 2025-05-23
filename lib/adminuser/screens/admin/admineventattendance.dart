
import 'package:flutter/material.dart';
import 'package:pdfplugin/adminuser/consts/colors.dart';
import 'package:pdfplugin/adminuser/widgets/mntxt.dart';

class EventAttendanceScreen extends StatelessWidget {
  const EventAttendanceScreen({super.key});

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
                if (screenwidth <= 600) mobileview(),
                if (screenwidth > 600 && screenwidth <= 992) tabview(),
                if (screenwidth > 992) webview()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget mobileview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Mntxt(txt: 'Event Attendance'),
        const SizedBox(height: 50),

        // Event tabs row
        Row(
          children: [
            // Tech Conference tab
            todisevent('Tech', 'Conference', 'Dec 15', true),
            const SizedBox(width: 12),
            // Design Workshop tab
            todisevent('Design', 'Workshop', 'Dec 18', false),
          ],
        ),

        const SizedBox(height: 16),

        // Attendee list
        Column(
          children: [
            AttendeeItem(
              name: 'Sarah Johnson',
              time: '9:30 AM',
              imagePath: 'assets/images/sarah.jpg',
              avatarColor: Colors.red[400]!,
            ),
            const SizedBox(height: 8),
            AttendeeItem(
              name: 'Michael Chen',
              time: '9:45 AM',
              imagePath: 'assets/images/michael.jpg',
              avatarColor: Colors.orange[300]!,
            ),
            const SizedBox(height: 8),
            AttendeeItem(
              name: 'Emily Davis',
              time: '10:15 AM',
              imagePath: 'assets/images/emily.jpg',
              avatarColor: Colors.blue[400]!,
            ),
          ],
        ),
      ],
    );
  }

  Widget tabview() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              Mntxt(txt: 'Event Attendance'),
              const SizedBox(height: 40),

              // Event Tabs Row
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  todisevent('Tech', 'Conference', 'Dec 15', true),
                  todisevent('Design', 'Workshop', 'Dec 18', false),
                ],
              ),

              const SizedBox(height: 24),

              // Attendees List
              const Text(
                'Attendees',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Attendee Cards
              Column(
                children: [
                  AttendeeItem(
                    name: 'Sarah Johnson',
                    time: '9:30 AM',
                    imagePath: 'assets/images/sarah.jpg',
                    avatarColor: Colors.red[400]!,
                  ),
                  const SizedBox(height: 12),
                  AttendeeItem(
                    name: 'Michael Chen',
                    time: '9:45 AM',
                    imagePath: 'assets/images/michael.jpg',
                    avatarColor: Colors.orange[300]!,
                  ),
                  const SizedBox(height: 12),
                  AttendeeItem(
                    name: 'Emily Davis',
                    time: '10:15 AM',
                    imagePath: 'assets/images/emily.jpg',
                    avatarColor: Colors.blue[400]!,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget webview() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Mntxt(txt: 'Event Attendance'),
            const SizedBox(height: 40),

            // Event Tabs Row
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                todisevent('Tech', 'Conference', 'Dec 15', true),
                todisevent('Design', 'Workshop', 'Dec 18', false),
              ],
            ),

            const SizedBox(height: 32),

            // Attendee List
            Column(
              children: [
                AttendeeItem(
                  name: 'Sarah Johnson',
                  time: '9:30 AM',
                  imagePath: 'assets/images/sarah.jpg',
                  avatarColor: Colors.red[400]!,
                ),
                const SizedBox(height: 12),
                AttendeeItem(
                  name: 'Michael Chen',
                  time: '9:45 AM',
                  imagePath: 'assets/images/michael.jpg',
                  avatarColor: Colors.orange[300]!,
                ),
                const SizedBox(height: 12),
                AttendeeItem(
                  name: 'Emily Davis',
                  time: '10:15 AM',
                  imagePath: 'assets/images/emily.jpg',
                  avatarColor: Colors.blue[400]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget todisevent(String fw, String lw, String dt, bool isclicked) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isclicked ? Usingcolors.btnbgcolor : Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fw,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            lw,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            dt,
            style: TextStyle(
              color: Color(0xFF1ED195),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class AttendeeItem extends StatelessWidget {
  final String name;
  final String time;
  final String imagePath;
  final Color avatarColor;

  const AttendeeItem({
    super.key,
    required this.name,
    required this.time,
    required this.imagePath,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Avatar with colored border
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: avatarColor,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                // Using a placeholder color since we don't have actual images
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: avatarColor,
                    child: Icon(
                      Icons.person,
                      color: avatarColor,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name and time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  color: Usingcolors.btnbgcolor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
