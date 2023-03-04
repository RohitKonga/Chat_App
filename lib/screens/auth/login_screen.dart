import 'dart:developer';
import 'dart:io';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _isanimate = false;
  @override
  void initState() {
    // ignore: todo
    //TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500), (){
      setState(() {
        _isanimate = true;
      });
    });
  }

  _handleGoogleBtnClick(){
    Dialogs.showProgressBar(context);
  _signInWithGoogle().then((user) async {
    Navigator.pop(context);
    if(user != null) {
      log('\nUser: ${user.user}');
      log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

      if((await APIs.userExists())){
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      }else{
        await APIs.createUser().then((value){
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        });
      }
    }
  });
  }

  Future<UserCredential?> _signInWithGoogle() async {
   try{
     await InternetAddress.lookup('google.com');
     // Trigger the authentication flow
     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

     // Obtain the auth details from the request
     final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

     // Create a new credential
     final credential = GoogleAuthProvider.credential(
       accessToken: googleAuth?.accessToken,
       idToken: googleAuth?.idToken,
     );

     // Once signed in, return the UserCredential
     return await APIs.auth.signInWithCredential(credential);
   }catch(e){
     log('\n_signInWithGoogle: $e');
     Dialogs.showSnackbar(context, 'Something Went Wrong (Check Your Internet Connection!)');
      return null;
   }
  }

  //sign out function
  // _signOut() async {
        //await FirebaseAuth.instance.sign0ut();
        //await GoogleSignIn(). signOut();}

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 5,
        centerTitle: true,
        title: Text('Welcome to My Chat'),
      ),

      body: Stack(children: [
        AnimatedPositioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            bottom: _isanimate ? mq.width * .75 : -mq.width * .2,
            duration: Duration(seconds: 3),
            child: Image.asset('images/dating-app1.png')),

        //google login button
        Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * 0.06,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 219, 255, 178),
                  shape: StadiumBorder(),
                  elevation: 1),
                onPressed: (){
                _handleGoogleBtnClick();
                },

                //google icon
                icon: Image.asset('images/google.png', height: mq.height * 0.03,),

                //login with google icon
                label: RichText(
                    text: TextSpan(
                        style: GoogleFonts.poppins(color: Colors.black, fontSize: 16),
                        children: [
                          TextSpan(text: 'Login with'),
                          TextSpan(text: ' Google',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500))
                ])))),
      ]),
    );
  }
}

