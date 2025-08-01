import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info(if null --. no messages)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: mq.width * .011, vertical: 5),
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        elevation: 0.1,
        child: InkWell(
            onTap: () {
              //for navigating to chat screen
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(user: widget.user)));
            },
            child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) _message = list[0];

                return ListTile(
                  //user profile picture
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => ProfileDialog(user: widget.user));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .03),
                      child: CachedNetworkImage(
                        width: mq.height * .055,
                        height: mq.height * .055,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) =>
                            CircleAvatar(child: Icon(CupertinoIcons.person)),
                      ),
                    ),
                  ),

                  //user name
                  title: Text(widget.user.name),

                  //last message
                  subtitle: Text(
                      _message != null
                          ? _message!.type == Type.image
                              ? 'image'
                              : _message!.msg
                          : widget.user.about,
                      maxLines: 1),

                  //last message time
                  trailing: _message == null
                      ? null //show nothing when no message is sent
                      : _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          //show for unread message
                          ? Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10)),
                            )
                          :
                          //message sent time
                          Text(
                              MyDateUtil.getLastMessageTime(
                                  context: context, time: _message!.sent),
                              style: GoogleFonts.poppins(color: Colors.black54)),
                );
              },
            )));
  }
}
