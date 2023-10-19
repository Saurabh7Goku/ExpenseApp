// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:eazyexpense/dashboard.dart';
import 'package:eazyexpense/expensedata.dart';
import 'package:eazyexpense/utils/profile_pic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

const projectId = "eztracker-d3096";

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProfileProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen();

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer(const Duration(milliseconds: 2500), () {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (context) => Auth()),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              Container(
                height: 60,
                color: Colors.deepPurple.shade50,
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Ez Tracker',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.deepPurpleAccent.shade100),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              ImageSlideshow(),
              SizedBox(
                height: 40,
              ),
              Center(
                child: Text(
                  'Welcome Mr. Singh',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                      color: CupertinoColors.systemPurple),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50, left: 20),
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width / 2.5,
              child: ElevatedButton.icon(
                onPressed: () async {
                  bool auth = await Authentication.authentication(context);
                  if (auth) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashBoard(),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.fingerprint),
                label: Text(
                  'Authenticate',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Authentication {
  static final auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async =>
      await auth.canCheckBiometrics || await auth.isDeviceSupported();

  static Future<bool> authentication(BuildContext context) async {
    try {
      if (!await canAuthenticate()) return false;
      return await auth.authenticate(
          localizedReason: 'Get Into The APP',
          options: const AuthenticationOptions(useErrorDialogs: false));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication error: $e'),
        ),
      );
      return false;
    }
  }
}

class ImageSlideshow extends StatefulWidget {
  @override
  _ImageSlideshowState createState() => _ImageSlideshowState();
}

class _ImageSlideshowState extends State<ImageSlideshow> {
  final List<String> images = [
    'assets/logoss.png',
    'assets/logo.png',
    'assets/logos.png',
  ];

  int currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Start a timer to automatically change the image index
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % images.length;
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: MediaQuery.of(context).size.width - 50,
      child: PageView.builder(
        itemCount: images.length,
        controller: PageController(
          initialPage: currentIndex,
        ),
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Image.asset(
            images[index],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
