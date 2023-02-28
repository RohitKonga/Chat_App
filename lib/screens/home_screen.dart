import 'dart:developer';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //for storing all users
  List<ChatUser> _list = [];

  //for storing searched items
  final List<ChatUser> _searchlist = [];

  //for storing each status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    //for updating user active according to lifecycle events
    //resume = active or online
    //pause = inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if search is on & back button is pressed then close search
        //or else simple close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          //app bar
          appBar: AppBar(
            // leading: Icon(CupertinoIcons.home),

            elevation: 3,
            centerTitle: true,
            title: _isSearching
                ? TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Name, Email...'),
                    autofocus: true,
                    style:
                        GoogleFonts.poppins(fontSize: 17, letterSpacing: 0.5),
                    //when search text changes then updated list
                    onChanged: (val) {
                      //search logic
                      _searchlist.clear();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchlist.add(i);
                        }
                        setState(() {
                          _searchlist;
                        });
                      }
                    })
                : Text('My Chat', style: GoogleFonts.poppins()),
            actions: [
              // search user button
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              // search features button
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: APIs.me)));
                  },
                  icon: Icon(Icons.more_vert))
            ],
          ),

          //floating button to add user
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () {
                _addChatUserDialog();
              },
              child: Icon(Icons.add_comment_rounded),
            ),
          ),

          //body
          body: StreamBuilder(
              stream: APIs.getMyUsersId(),

              //get id of only known users
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                  //return Center(child: CircularProgressIndicator());

                  //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                      stream: APIs.getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                      //get only those who's ids are provided
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                          //return Center(child: CircularProgressIndicator());

                          //if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => ChatUser.fromJson(e.data()))
                                    .toList() ??
                                [];
                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  itemCount: _isSearching
                                      ? _searchlist.length
                                      : _list.length,
                                  //padding: EdgeInsets.only(top: mq.height * 0.01),
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ChatUserCard(
                                        user: _isSearching
                                            ? _searchlist[index]
                                            : _list[index]);
                                    // return Text('Name: ${list[index]}');
                                  });
                            } else {
                              return Center(
                                child: Text('No Connection Found!!',
                                    style: GoogleFonts.poppins(fontSize: 20)),
                              );
                            }
                        }
                      },
                    );
                }
              }),
        ),
      ),
    );
  }

//for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, bottom: 10, top: 20),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(Icons.person_add, color: Colors.blue, size: 28),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                style: GoogleFonts.poppins(),
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style:
                          GoogleFonts.poppins(color: Colors.blue, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackbar(
                                context, 'User Does Not Exist!!');
                          }
                        });
                      }
                    },
                    child: Text(
                      'Add',
                      style:
                          GoogleFonts.poppins(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}
