import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';


//view profile screen to view profile of user
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super. key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 3,
          centerTitle: true,
          title: Text(widget.user.name)),

        floatingActionButton:               //user email label
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Joined On : ', style:
            GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 18)
            ),
            Text(MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt, showYear: true),
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 18)),
          ],
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            child: Column(
                children: [
              //for adding some space
              SizedBox(width: mq.width, height: mq.height * .03,),

              //user profile picture
                 ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) =>
                        CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                 ),
              //for adding soe space
              SizedBox(height: mq.height * .03,),

              //user email label
              Text(widget.user.email, style: GoogleFonts.poppins(color: Colors.black87, fontSize: 18)),

              SizedBox(height: mq.height * .03),

              //user email label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('About: ', style:
                  GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 17)),

                  Text(widget.user.about, style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16.5)),
                ],
              ),

            ]),
          ),
        )),
    );
  }
}