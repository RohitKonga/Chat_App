// import 'dart:convert';
//import 'dart:developer';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import 'package:chat_app/models/message.dart';
import '../main.dart';
import '../models/chat_user.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //FOR STORING ALL MESSAGES
  List<Message> _list = [];

  //for handling all text message
  final _textController = TextEditingController();

  //_showEmoji for storing value of showing or hiding emojis
  //_isUploading = for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          // if search is on & back button is pressed then close search
          //or else simple close current screen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            //App Bar
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            //backgroundColor: Colors.white,
            backgroundColor: Color.fromARGB(255, 234, 248, 255),
            //body
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return SizedBox();

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                //padding: EdgeInsets.only(top: mq.height * 0.01),
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(message: _list[index]);
                                });
                          } else {
                            return Center(
                              child: Text('Hello! Welcome to the Chat👋',
                                  style: GoogleFonts.poppins(fontSize: 20)),
                            );
                          }
                      }
                    },
                  ),
                ),

                //progress indicator for showing uploading
                if (_isUploading)
                  Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ))),

                //chat input field
                _chatInput(),

                //show emojis on keyboard emoji button click & vice versa
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * 0.25,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: Colors.white,
                        columns: 8,
                        initCategory: Category.SMILEYS,
                        emojiSizeMax: 28 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //app bar widget
  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
                children: [
                  //Back Button
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: Colors.white)),

                  //user profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      width: mq.height * .045,
                      height: mq.height * .045,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) =>
                          CircleAvatar(child: Icon(CupertinoIcons.person)),
                    ),
                  ),

                  //Sized Box
                  SizedBox(
                    width: 10,
                  ),

                  //user name & last seen
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //user name
                      Text(list.isNotEmpty ? list[0].name : widget.user.name,
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),

                      //Sized Box
                      SizedBox(height: 2),

                      //last seen time of user
                      Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive),
                          style: GoogleFonts.poppins(
                              fontSize: 15, color: Colors.white70)),
                    ],
                  )
                ],
              );
            }));
  }

  //bottom chat input field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0.01, horizontal: mq.width * 0.025),
      child: Row(children: [
        //input field & button
        Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
            child: Row(
              children: [
                //emoji button
                IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: Icon(Icons.emoji_emotions,
                        color: Colors.blue, size: 25)),

                //Text Box
                Expanded(
                    child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onTap: () {
                    if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                  },
                  decoration: InputDecoration(
                      hintText: 'Type Something...',
                      hintStyle:
                          GoogleFonts.poppins(color: Colors.blue, fontSize: 18),
                      border: InputBorder.none),
                )),

                //image picker from gallery
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      //picking multiple images
                      final List<XFile> images = await picker.pickMultiImage();

                      //uploading & sending image one by one
                      for (var i in images) {
                        log('Image Path: ${i.path}');
                        setState(() => _isUploading = true);
                        await APIs.sendChatImage(widget.user, File(i.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: Icon(Icons.image, color: Colors.blue, size: 26)),

                //image picker from camera
                IconButton(
                    onPressed: () async {
                      // Pick an image
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(() => _isUploading = true);
                        await APIs.sendChatImage(widget.user, File(image.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: Icon(Icons.camera_alt_rounded,
                        color: Colors.blue, size: 26)),

                //Sized Box
                SizedBox(width: mq.width * 0.02)
              ],
            ),
          ),
        ),

        //send message button
        MaterialButton(
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              if (_list.isEmpty) {
                //on first message (add user to my_user collection of chat user)
                APIs.sendFirstMessage(
                    widget.user, _textController.text, Type.text);
              } else {
                //simply send message
                APIs.sendMessage(widget.user, _textController.text, Type.text);
              }
              _textController.text = '';
            }
          },
          minWidth: 0,
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
          shape: CircleBorder(),
          color: Colors.green,
          child: Icon(Icons.send, color: Colors.white, size: 28),
        )
      ]),
    );
  }
}
