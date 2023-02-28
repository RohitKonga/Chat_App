import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
          width: mq.width * 0.6,
          height: mq.height * 0.35,
          child: Stack(
            children: [
              //user profile picture
              Positioned(
                top: mq.height * 0.068,
                left: mq.width * 0.1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .25),
                  child: CachedNetworkImage(
                   height: mq.height * .23,
                    width: mq.width * .5,
                    fit: BoxFit.cover,
                    imageUrl: user.image,
                    errorWidget: (context, url, error) =>
                        CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
              ),

              //user name
              Positioned(
                top: mq.height * 0.02,
                left: mq.width * 0.05,
                width: mq.width * 0.55,
                child: Text(
                    user.name,
                    style: GoogleFonts.poppins(
                        color: Colors.black, 
                        fontSize: 19,
                        fontWeight: FontWeight.w500)),
              ),

              //info button
              Positioned(
                  top: 4,
                  right: 8,
                  child: MaterialButton(onPressed: (){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: user)));
                  },
                      minWidth: 0,
                      padding: EdgeInsets.all(0),
                      shape: CircleBorder(),
                    child:
                    Icon(Icons.info_outlined,
                        color: Colors.blue,
                        size: 25))),
            ]))
    );
  }
}
