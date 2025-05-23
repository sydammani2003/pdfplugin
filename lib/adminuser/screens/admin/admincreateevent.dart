
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdfplugin/adminuser/consts/colors.dart';
import 'package:pdfplugin/adminuser/widgets/custombutton.dart';
import 'package:pdfplugin/adminuser/widgets/customtxtfield.dart';
import 'package:pdfplugin/adminuser/widgets/mntxt.dart';
import 'package:pdfplugin/adminuser/widgets/txtiph.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  String sp = '';
  String ps = '';
  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenwidth = mediaquery.size.width;

    return Scaffold(
      backgroundColor: Usingcolors.bgcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (screenwidth <= 600) mobileview(context),
                if (screenwidth > 600 && screenwidth <= 992) tabview(),
                if (screenwidth > 992) webview()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget mobileview(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Header
          Mntxt(txt: 'Create an Event'),
          const SizedBox(height: 24),

          // Improved Image upload container
          Center(
            child: InkWell(
              onTap: () {
                // Implement image picker here
              },
              child: toaddimage(),
            ),
          ),

          const SizedBox(height: 24),
          // Event Title
          Txtiph(txt: 'Event Title'),
          const SizedBox(height: 8),
          // Title TextField
          Customtxtfield(
            txt: 'Event Title',
          ),
          const SizedBox(height: 16),
          // Description
          Txtiph(txt: 'Description'),
          const SizedBox(height: 8),
          // Description TextField
          Customtxtfield(
            txt: 'Enter the description',
            lines: 5,
          ),
          const SizedBox(height: 16),
          // Date and Time row
          Row(
            children: [
              // Date
              GestureDetector(
                child: toadddttime('Date', sp, Icons.calendar_today),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  setState(() {
                    sp =
                        "${pickedDate!.day.toString()}-${pickedDate.month.toString()}-${pickedDate.year.toString()}";
                  });
                  // You'd store the date in a variable in a StatefulWidget
                },
              ),
              const SizedBox(width: 16),
              // Time
              GestureDetector(
                  child: toadddttime('Time', ps, Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      ps =
                          '${pickedTime!.hour.toString()}:${pickedTime.minute.toString()}';
                    });
                    // You'd store the time in a variable in a StatefulWidget
                  }),
            ],
          ),

          // Create Event Button
          SizedBox(
              height: 20,
            ),
            // Create Button
            Custombutton(txt: 'Create',call: () {
              
            },calllong: () {
              
            },),
          
        ],
      ),
    );
  }

  Widget tabview() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // Header
            Mntxt(txt: 'Create an Event'),
            const SizedBox(height: 24),

            // Image Upload
            Center(
              child: InkWell(
                onTap: () {
                  // Implement image picker here
                },
                child: toaddimage(),
              ),
            ),
            const SizedBox(height: 24),

            // Event Title
            Txtiph(txt: 'Event Title'),
            const SizedBox(height: 8),
            Customtxtfield(txt: 'Event Title'),
            const SizedBox(height: 16),

            // Description
            Txtiph(txt: 'Description'),
            const SizedBox(height: 8),
            Customtxtfield(
              txt: 'Enter the description',
              lines: 5,
            ),
            const SizedBox(height: 16),

            // Date and Time Side-by-Side
            Row(
              children: [
                GestureDetector(
                  child: toadddttime('Date', sp, Icons.calendar_today),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    setState(() {
                      sp =
                          "${pickedDate!.day.toString()}-${pickedDate.month.toString()}-${pickedDate.year.toString()}";
                    });
                    // You'd store the date in a variable in a StatefulWidget
                  },
                ),
                const SizedBox(width: 16),
                // Time
                GestureDetector(
                    child: toadddttime('Time', ps, Icons.access_time),
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      setState(() {
                        ps =
                            '${pickedTime!.hour.toString()}:${pickedTime.minute.toString()}';
                      });
                      // You'd store the time in a variable in a StatefulWidget
                    }),
              ],
            ),

            // Create Button
            SizedBox(
              height: 20,
            ),
            // Create Button
            Custombutton(txt: 'Create',call: () {
              
            },calllong: () {
              
            },),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // Header
            Mntxt(txt: 'Create an Event'),
            const SizedBox(height: 32),

            // Image Upload Container
            Center(
              child: InkWell(
                onTap: () {
                  // Implement image picker here
                },
                child: toaddimage(),
              ),
            ),

            const SizedBox(height: 32),

            // Event Title
            Txtiph(txt: 'Event Title'),
            const SizedBox(height: 8),
            Customtxtfield(txt: 'Event Title'),
            const SizedBox(height: 24),

            // Description
            Txtiph(txt: 'Description'),
            const SizedBox(height: 8),
            Customtxtfield(
              txt: 'Enter the description',
              lines: 5,
            ),
            const SizedBox(height: 24),

            // Date & Time Row
            LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 500;
                return isWide
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            child:
                                toadddttime('Date', sp, Icons.calendar_today),
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              setState(() {
                                sp =
                                    "${pickedDate!.day.toString()}-${pickedDate.month.toString()}-${pickedDate.year.toString()}";
                              });
                              // You'd store the date in a variable in a StatefulWidget
                            },
                          ),
                          const SizedBox(width: 16),
                          // Time
                          GestureDetector(
                              child: toadddttime('Time', ps, Icons.access_time),
                              onTap: () async {
                                final TimeOfDay? pickedTime =
                                    await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                setState(() {
                                  ps =
                                      '${pickedTime!.hour.toString()}:${pickedTime.minute.toString()}';
                                });
                                // You'd store the time in a variable in a StatefulWidget
                              }),
                        ],
                      )
                    : Column(
                        children: [
                          GestureDetector(
                            child:
                                toadddttime('Date', sp, Icons.calendar_today),
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              setState(() {
                                sp =
                                    "${pickedDate!.day.toString()}-${pickedDate.month.toString()}-${pickedDate.year.toString()}";
                              });
                              // You'd store the date in a variable in a StatefulWidget
                            },
                          ),
                          const SizedBox(width: 16),
                          // Time
                          GestureDetector(
                              child: toadddttime('Time', ps, Icons.access_time),
                              onTap: () async {
                                final TimeOfDay? pickedTime =
                                    await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                setState(() {
                                  ps =
                                      '${pickedTime!.hour.toString()}:${pickedTime.minute.toString()}';
                                });
                                // You'd store the time in a variable in a StatefulWidget
                              }),
                        ],
                      );
              },
            ),
            SizedBox(
              height: 20,
            ),
            // Create Button
            Custombutton(txt: 'Create',call: () {
              
            },calllong: () {
              
            },),
          ],
        ),
      ),
    );
  }

  Widget toadddttime(String iph, String hinttxt, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txtiph(txt: iph),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 50),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  icon,
                  color: Usingcolors.iconscolor,
                  size: 18,
                ),
                SizedBox(width: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    hinttxt,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget toaddimage() {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/images/FRAME (1).svg', // Update with your SVG asset path
          width: 122,
          height: 102,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Add Event images',
          style: TextStyle(
            color: Usingcolors.iconscolor,
            fontSize: 14,
          ),
        )
      ],
    );
  }
}
