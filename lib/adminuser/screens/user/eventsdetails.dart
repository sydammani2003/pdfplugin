// ignore_for_file: deprecated_member_use


import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pdfplugin/adminuser/consts/colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EventDetailsScreen extends StatelessWidget {
  EventDetailsScreen({super.key});
  final List<String> img = [
    'https://picsum.photos/id/237/500/300',
    'https://picsum.photos/seed/picsum/500/300',
    'https://picsum.photos/500/300?grayscale',
    'https://picsum.photos/500/300/',
    'https://picsum.photos/id/870/500/300'
  ];

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenwidth = mediaquery.size.width;
    return Scaffold(
      backgroundColor: Usingcolors.bgcolor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: Usingcolors.mainhcolor,
          ),
        ),
        title: const Text(
          'Event Details',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Usingcolors.mainhcolor),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (screenwidth <= 600) mobileview(),
            if (screenwidth > 600 && screenwidth <= 992) tabview(),
            if (screenwidth > 992) webview()
          ],
        ),
      ),
    );
  }

  Widget mobileview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Image with Carousel Indicator

        const SizedBox(height: 16),
        CarouselSlider(
            items: img.map((e) => Center(child: Image.network(e))).toList(),
            options: CarouselOptions(
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 1))),
        SizedBox(
          height: 10,
        ),
        // Event Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Summer Music Festival 2024',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Usingcolors.mainhcolor),
          ),
        ),

        const SizedBox(height: 8),

        // Date and Time
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: const [
              Icon(
                Icons.access_time,
                color: Usingcolors.btnbgcolor,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'June 15, 2024 • 7:00 PM',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Event Description
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Join us for an unforgettable evening of live music under the stars. Featuring top artists from around the world, this festival promises to be the highlight of your summer.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // QR Code Section
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Scan this QR Code to Join',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Usingcolors.mainhcolor),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    color: Usingcolors.mainhcolor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(
                    data:
                        "{\"name\": \"New York City\", \"latitude\": 40.7128, \"longitude\": -74.006}",
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Home Indicator

        const SizedBox(height: 8),
      ],
    );
  }

  Widget tabview() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image with Carousel Indicator
              const SizedBox(height: 16),
              CarouselSlider(
                items: img.map((e) => Center(child: Image.network(e))).toList(),
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                ),
              ),
              const SizedBox(height: 10),

              // Event Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Summer Music Festival 2024',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Usingcolors.mainhcolor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Date and Time
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Icon(
                      Icons.access_time,
                      color: Usingcolors.btnbgcolor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'June 15, 2024 • 7:00 PM',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Event Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Join us for an unforgettable evening of live music under the stars. Featuring top artists from around the world, this festival promises to be the highlight of your summer.',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // QR Code Section
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Scan this QR Code to Join',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Usingcolors.mainhcolor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Usingcolors.mainhcolor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: QrImageView(
                          data:
                              "{\"name\": \"New York City\", \"latitude\": 40.7128, \"longitude\": -74.006}",
                          version: QrVersions.auto,
                          size: 220.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Home Indicator (Optional)
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget webview() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image with Carousel Indicator
              const SizedBox(height: 16),
              CarouselSlider(
                items: img.map((e) => Center(child: Image.network(e))).toList(),
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(
                      seconds: 3), // Slower autoplay for better viewing
                ),
              ),
              const SizedBox(height: 10),

              // Event Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Summer Music Festival 2024',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Usingcolors.mainhcolor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Date and Time
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: const [
                    Icon(
                      Icons.access_time,
                      color: Usingcolors.btnbgcolor,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'June 15, 2024 • 7:00 PM',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Event Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Join us for an unforgettable evening of live music under the stars. Featuring top artists from around the world, this festival promises to be the highlight of your summer.',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // QR Code Section
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Scan this QR Code to Join',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Usingcolors.mainhcolor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Usingcolors.mainhcolor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: QrImageView(
                          data:
                              "{\"name\": \"New York City\", \"latitude\": 40.7128, \"longitude\": -74.006}",
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Home Indicator
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
