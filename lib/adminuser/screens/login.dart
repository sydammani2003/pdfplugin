// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pdfplugin/adminuser/consts/colors.dart';
import 'package:pdfplugin/adminuser/screens/admin/adminhome.dart';
import 'package:pdfplugin/adminuser/screens/user/userevents.dart';
import 'package:pdfplugin/adminuser/widgets/custombutton.dart';
import 'package:pdfplugin/adminuser/widgets/customtxtfield.dart';
import 'package:pdfplugin/adminuser/widgets/mntxt.dart';
import 'package:pdfplugin/adminuser/widgets/txtiph.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  TextEditingController un = TextEditingController();
  TextEditingController pw = TextEditingController();

  // Future<void> saveLoginCredentials() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('adminusername', 'admin');
  //   await prefs.setString('adminpassword', 'adminpass');
  //   await prefs.setString('userusername', 'user');
  //   await prefs.setString('userpassword', 'userpass');
  // }

  // Future<String> getLoginCredentials(String username, String password) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final adminusername = prefs.getString('adminusername');
  //   final adminpassword = prefs.getString('adminpassword');
  //   final userusername = prefs.getString('userusername');
  //   final userpassword = prefs.getString('userpassword');

  //   if (adminusername == username && adminpassword == password) {
  //     return 'admin';
  //   } else if (userusername == username && userpassword == password) {
  //     return 'user';
  //   } else {
  //     return 'Invalid Login Credentials';
  //   }
  // }

  String s = '';

  @override
  void initState() {
    super.initState();
    // saveLoginCredentials();
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenwidth = mediaquery.size.width;
    return Scaffold(
      backgroundColor: Usingcolors.bgcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Usingcolors.iconscolor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Usingcolors.btntxtcolor,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Mntxt(txt: 'Welcome Back'),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 14,
                      color: Usingcolors.hinttxt,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                if (screenwidth <= 600) mobileview(),
                if (screenwidth > 600 && screenwidth <= 992) tabletview(),
                if (screenwidth > 992) webview(),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Usingcolors.iconscolor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget mobileview() {
    return Column(
      children: [
        Txtiph(txt: 'Username'),
        const SizedBox(height: 8),
        Customtxtfield(
          crtl: un,
          txt: 'Enter Username',
        ),
        const SizedBox(height: 20),
        Txtiph(txt: 'Password'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: pw,
            obscureText: _obscureText,
            style: const TextStyle(color: Usingcolors.mainhcolor),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: const TextStyle(color: Usingcolors.hinttxt),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Usingcolors.iconscolor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Custombutton(
          txt: 'Login',
          call: () {
            if (un.text == 'admin') {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => HomeScreen()));
            } else if (un.text == 'user') {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => EventsScreen()));
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(s)));
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget tabletview() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Txtiph(txt: 'Username'),
              const SizedBox(height: 8),
              Customtxtfield(
                txt: 'Enter Username',
                crtl: un,
              ),
              const SizedBox(height: 20),
              Txtiph(txt: 'Password'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: pw,
                  obscureText: _obscureText,
                  style: const TextStyle(color: Usingcolors.mainhcolor),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(color: Usingcolors.hinttxt),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Usingcolors.iconscolor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Custombutton(
                txt: 'Login',
                call: () {
                  if (un.text == 'admin') {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => HomeScreen()));
                  } else if (un.text == 'user') {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => EventsScreen()));
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(s)));
                  }
                },
              ),
              const SizedBox(height: 16),
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
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Txtiph(txt: 'Username'),
              const SizedBox(height: 8),
              Customtxtfield(
                txt: 'Enter Username',
                crtl: un,
              ),
              const SizedBox(height: 20),
              Txtiph(txt: 'Password'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: pw,
                  obscureText: _obscureText,
                  style: const TextStyle(color: Usingcolors.mainhcolor),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(color: Usingcolors.hinttxt),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Usingcolors.iconscolor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Custombutton(
                txt: 'Login',
                call: () {
                  if (un.text == 'admin') {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => HomeScreen()));
                  } else if (un.text == 'user') {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => EventsScreen()));
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(s)));
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
