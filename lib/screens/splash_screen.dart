import 'dart:developer';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/screens/auth/login_or_register_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 2000), () {
      //exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white, statusBarColor: Colors.blue));

      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => LoginOrRegisterScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      // body
      body: Stack(children: [
        Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            bottom: mq.height * .28,
            child: Image.asset('images/dating-app1.png')),

        //google login button
        Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            top: mq.height * 0.79,
            child: Text('MADE IN INDIA WITH 💙',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.black87, letterSpacing: 1.5)))
      ]),
    );
  }
}
