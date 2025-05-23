
import 'package:flutter/material.dart';
import 'package:pdfplugin/adminuser/screens/admin/admincreateevent.dart';
import 'package:pdfplugin/adminuser/screens/admin/admineventattendance.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Replace these placeholders with your actual page widgets
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Add your pages here
    _pages = [
      // Replace with your actual page widgets:
      // Example: CreateEventPage(),
      // Example: AttendancePage(),
      CreateEventScreen(),
      EventAttendanceScreen() // Replace with your Attendance page
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenwidth = mediaquery.size.width;
    

    return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
            color: Colors.black,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (screenwidth <= 600) mobileview(),
              if (screenwidth > 600 && screenwidth <= 992) tabletview(),
              if (screenwidth > 992) webview()
            ])));
  }

  Widget mobileview() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 70,
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Create Tab
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: _selectedIndex == 0
                          ? const Color(0xFF1ED195)
                          : Colors.grey,
                      size: 30,
                    ),
                    Text(
                      'Create',
                      style: TextStyle(
                        color: _selectedIndex == 0
                            ? const Color(0xFF1ED195)
                            : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Attendance Tab
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      color: _selectedIndex == 1
                          ? const Color(0xFF1ED195)
                          : Colors.grey,
                      size: 30,
                    ),
                    Text(
                      'Attendance',
                      style: TextStyle(
                        color: _selectedIndex == 1
                            ? const Color(0xFF1ED195)
                            : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal indicator
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
          height: 5,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget tabletview() {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 600), // Keep nav bar compact
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80, // Increased height for tablet
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Create Tab
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.white10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: _selectedIndex == 0
                                ? const Color(0xFF1ED195)
                                : Colors.grey,
                            size: 34, // Slightly larger for tablet
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Create',
                            style: TextStyle(
                              color: _selectedIndex == 0
                                  ? const Color(0xFF1ED195)
                                  : Colors.grey,
                              fontSize: 18, // Larger font for tablet
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Attendance Tab
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.white10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people,
                            color: _selectedIndex == 1
                                ? const Color(0xFF1ED195)
                                : Colors.grey,
                            size: 34,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Attendance',
                            style: TextStyle(
                              color: _selectedIndex == 1
                                  ? const Color(0xFF1ED195)
                                  : Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal indicator
            Container(
              width: 200,
              height: 6,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget webview() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Create Tab
                _buildNavItem(
                  icon: Icons.add,
                  label: 'Create',
                  index: 0,
                ),

                // Attendance Tab
                _buildNavItem(
                  icon: Icons.people,
                  label: 'Attendance',
                  index: 1,
                ),
              ],
            ),

            // Indicator (optional for web)
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: MediaQuery.of(context).size.width * 0.2,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1ED195) : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1ED195) : Colors.grey,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
