import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/DataAPI.dart';
import 'package:degree/Video_call_screen.dart';
import 'package:degree/pages/chat_more_screen.dart';
import 'package:degree/pages/home.dart';
import 'package:degree/service/Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/database.dart';

class ChatPage extends StatefulWidget {
  final String name, profileurl, username, channel, userId;
  const ChatPage(
      {required this.name,
      required this.profileurl,
      required this.username,
      required this.channel,
      required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  DataController _dataController = Get.find();
  TextEditingController messagecontroller = new TextEditingController();
  String? myUserName, myProfilePic, myName, myEmail, messageId, chatRoomId;
  Stream? messageStream;
  int translation_status = 1;
  var args;

  getthesharedpref() async {
    myUserName = _dataController.myusername;
    myName = _dataController.myname;
    myProfilePic = _dataController.picUrl;
    myEmail = _dataController.email;

    print(
        'name $myName, usrname: $myUserName, pic: $myProfilePic, id: $myEmail, exited:${_dataController.exitedForEachChannel[myUserName]} ');
    chatRoomId = widget.channel;
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    await getAndSetMessages();
    _dataController
        .exitedForEachChannel[myUserName ?? _dataController.myusername] = false;

    print('listening in chatpage name: ${widget.channel}');
    _dataController.startListeningToLastMessage(
        widget.channel, myUserName!, widget.username);

    setState(() {});
  }

//

  @override
  void initState() {
    super.initState();
    ontheload();

    print('object');
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight:
                      sendByMe ? Radius.circular(0) : Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft:
                      sendByMe ? Radius.circular(24) : Radius.circular(0)),
              color: sendByMe
                  ? Color.fromARGB(255, 234, 236, 240)
                  : Color.fromARGB(255, 211, 228, 243)),
          child: Text(
            message,
            style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.w500),
          ),
        )),
      ],
    );
  }

  Widget chatMessage() {
    return StreamBuilder(
        stream: messageStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 90.0, top: 130),
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];

                    return chatMessageTile(
                        ds["message"], myUserName == ds["sendBy"]);
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  List<String> voice_in_lans = [
    'Halh Mongolian',
    'Bengali',
    'Catalan',
    'Czech',
    'Danish',
    'Dutch',
    'English',
    'Estonian',
    'Finnish',
    'French',
    'German',
    'Hindi',
    'Indonesian',
    'Italian',
    'Japanese',
    'Korean',
    'Maltese',
    'Mandarin Chinese',
    'Modern Standard Arabic',
    'Northern Uzbek',
    'Polish',
    'Portuguese',
    'Romanian',
    'Russian',
    'Slovak',
    'Spanish',
    'Swahili',
    'Swedish',
    'Tagalog',
    'Telugu',
    'Thai',
    'Turkish',
    'Ukrainian',
    'Urdu',
    'Vietnamese',
    'Welsh',
    'Western Persian'
  ];

  final List<String> chat_in_lans = [
    'Halh Mongolian',
    'Bengali',
    'Catalan',
    'Czech',
    'Danish',
    'Dutch',
    'English',
    'Estonian',
    'Finnish',
    'French',
    'German',
    'Hindi',
    'Indonesian',
    'Italian',
    'Japanese',
    'Korean',
    'Maltese',
    'Mandarin Chinese',
    'Modern Standard Arabic',
    'Northern Uzbek',
    'Polish',
    'Portuguese',
    'Romanian',
    'Russian',
    'Slovak',
    'Spanish',
    'Swahili',
    'Swedish',
    'Tagalog',
    'Telugu',
    'Thai',
    'Turkish',
    'Ukrainian',
    'Urdu',
    'Vietnamese',
    'Welsh',
    'Western Persian'
  ];
  List<String> voice_out_lans = [];

  List<String> chat_out_lans = [];

  String? selectedValueFrom;
  String? selectedValueTo;
  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments;

    voice_out_lans = args as List<String>;
    print('args- $args');
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Color(0xFF553370),
      body: Container(
        child: Stack(
          children: [
            Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: chatMessage()),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              alignment: Alignment.bottomCenter,
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: TextField(
                    controller: messagecontroller,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message",
                        hintStyle: TextStyle(color: Colors.black45),
                        suffixIcon: GestureDetector(
                            onTap: () {
                              _dataController.addMessage(
                                  widget.channel,
                                  messagecontroller.text,
                                  selectedValueFrom ?? "Halh Mongolian",
                                  selectedValueTo ?? "Halh Mongolian",
                                  widget.username,
                                  widget.name);

                              messagecontroller.clear();
                            },
                            child: Icon(Icons.send_rounded))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      elevation: 0.5,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 70,
              child: Row(
                //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      _dataController.exitedForEachChannel[
                          myUserName ?? _dataController.myusername] = true;
                      Get.to(Home());
                    },
                    icon: Image.asset('assets/images/ic_chevron_left.png',
                        height: 20, width: 20, color: Colors.black),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.black.withOpacity(0.5))),
                    width: 55,
                    height: 55,
                    child: myProfilePic != null
                        ? ClipOval(
                            child: Image.network(
                            widget.profileurl,
                            fit: BoxFit.cover,
                          ))
                        : Offstage(),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    direction: Axis.vertical,
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Text(
                        widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.username,
                        //  LimeChatHelper.getChannelUserNumber(channel),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Spacer(),
                  Visibility(
                    visible: true,
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 24,
                      child: RawMaterialButton(
                        onPressed: () async {
                          //if (translation_status % 2 == 0) {
                          int intValue = Random().nextInt(10000);
                          String token = await Data.generate_token(
                              widget.channel, intValue);

                          print('channel token $token, uid: $intValue');
                          Get.to(Video_call_screen(
                              widget.channel,
                              myUserName!,
                              widget.username,
                              selectedValueFrom ?? 'Halh Mongolian',
                              selectedValueTo ?? 'English',
                              token,
                              intValue));
                          // } else {
                          //   Fluttertoast.showToast(
                          //     msg: 'Ta voice translation icon-ийг сонгоно уу.',
                          //     toastLength: Toast.LENGTH_SHORT,
                          //     gravity: ToastGravity.BOTTOM,
                          //     timeInSecForIosWeb: 1,
                          //     backgroundColor:
                          //         Color.fromARGB(255, 199, 197, 197),
                          //     textColor: Colors.black,
                          //   );
                          // }
                        },
                        shape: const CircleBorder(),
                        child: Image.asset("assets/images/ic_chat_video.png",
                            color: Get.theme.colorScheme.secondary,
                            width: 20,
                            height: 20),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: 20,
                  // ),
                  Visibility(
                    visible: true,
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 24,
                      child: RawMaterialButton(
                        onPressed: () {
                          Get.to(Chat_more_screen(
                              widget.userId,
                              widget.name,
                              widget.profileurl,
                              voice_out_lans,
                              voice_in_lans));
                        },
                        shape: const CircleBorder(),
                        child: Image.asset("assets/images/ic_chat_more.png",
                            color: Get.theme.colorScheme.secondary,
                            width: 20,
                            height: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('closing chatpage');
    _dataController
        .exitedForEachChannel[myUserName ?? _dataController.myusername] = true;
    // lastMessageStream?.cancel();
    super.dispose();
  }
}
