import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/dialogs.dart';
import '../main.dart';

//to show signed in user information
class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
              elevation: 3,
              centerTitle: true,
              title: Text('Profile', style: GoogleFonts.poppins())),

          //logout button
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
                backgroundColor: Colors.redAccent,
                onPressed: () async {
                  Dialogs.showProgressBar(context);

                  await APIs.updateActiveStatus(false);

                  //sign out from app
                  await APIs.auth.signOut().then((value) async {
                    await GoogleSignIn().signOut().then((value) {
                      //for hiding progress dialog
                      Navigator.pop(context);

                      //for moving to home screen
                      Navigator.pop(context);

                      APIs.auth = FirebaseAuth.instance;

                      //replacing home with login screen
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => LoginPage(onTap: () {  },)));
                    });
                  });
                },
                icon: Icon(Icons.logout_outlined),
                label:
                    Text('Logout', style: GoogleFonts.poppins(fontSize: 16))),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(children: [
                  //for adding soe space
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),

                  //user profile picture
                  Stack(
                    children: [
                      //profile picture
                      _image != null
                          ?

                          //local image
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ))
                          :

                          //image from server
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: CachedNetworkImage(
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                        child: Icon(CupertinoIcons.person)),
                              ),
                            ),

                      //eit image button
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                              elevation: 1,
                              onPressed: () {
                                _showBottomSheet();
                              },
                              shape: CircleBorder(),
                              color: Colors.white,
                              child: Icon(
                                Icons.edit,
                                color: Colors.blue,
                              )))
                    ],
                  ),
                  //for adding soe space
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  Text(widget.user.email,
                      style: GoogleFonts.poppins(
                          color: Colors.black54, fontSize: 18)),

                  SizedBox(height: mq.height * .05),

                  TextFormField(
                    style: GoogleFonts.poppins(),
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty
                        ? null
                        : '* Required Field',
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'e.g. Happy Singh',
                        label: Text(' Name ', style: GoogleFonts.poppins())),
                  ),

                  SizedBox(height: mq.height * .02),

                  TextFormField(
                    style: GoogleFonts.poppins(),
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty
                        ? null
                        : '* Required Field',
                    decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.info_outlined, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'e.g. Feeling Great Today 😍',
                        label: Text(' About ', style: GoogleFonts.poppins())),
                  ),

                  SizedBox(height: mq.height * .05),

                  //update button
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          backgroundColor: Colors.blue,
                          minimumSize: Size(mq.width * .5, mq.height * .05)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Dialogs.showSnackbar(
                                context, 'Profile Updated Successfully');
                          });
                        }
                      },
                      icon: Icon(Icons.exit_to_app_sharp),
                      label: Text('Update',
                          style: GoogleFonts.poppins(fontSize: 16)))
                ]),
              ),
            ),
          )),
    );
  }

  //bottom sheet for picking profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * 0.05),
            children: [
              Text('Profile Picture',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(height: mq.height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //take picture from gallery
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));
                          //for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/add_image.png')),

                  //take picture from camera
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));
                          //for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
