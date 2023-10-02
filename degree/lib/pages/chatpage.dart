import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/Data.dart';
import 'package:degree/Video_call_screen.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../service/database.dart';
import '../service/shared_pref.dart';
import 'package:random_string/random_string.dart';
import 'package:just_audio/just_audio.dart';
import 'package:degree/custom_source.dart';

class ChatPage extends StatefulWidget {
  final String name, profileurl, username, channel;
  const ChatPage(
      {required this.name,
      required this.profileurl,
      required this.username,
      required this.channel});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messagecontroller = new TextEditingController();
  String? myUserName, myProfilePic, myName, myEmail, messageId, chatRoomId;
  Stream? messageStream;

  getthesharedpref() async {
    myUserName = await SharedPreferenceHelper().getUserName();
    myProfilePic = await SharedPreferenceHelper().getUserPic();
    myName = await SharedPreferenceHelper().getDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

    chatRoomId = getChatRoomIdbyUsername(widget.username, myUserName!);
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    await getAndSetMessages();

    setState(() {});
  }

//

  @override
  void initState() {
    super.initState();
    ontheload();
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

                    if (ds["type"] == "text") {
                      log('chat: ${ds["message"]}');
                      return chatMessageTile(
                          ds["message"], myUserName == ds["sendBy"]);
                    } else {
                      log('audio render');
                      return Offstage();
                    }
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  addMessage(bool sendClicked) async {
    if (messagecontroller.text != "") {
      String message = messagecontroller.text;
      messagecontroller.text = "";

      String translation_text =
          await Data.sendText(message, "English", "Halh Mongolian");
      message = message + "\n ${translation_text}";

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap = {
        "type": "text",
        "message": message,
        "sendBy": myUserName,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myProfilePic,
      };
      messageId ??= randomAlphaNumeric(10);

      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": myUserName,
        };
        DatabaseMethods()
            .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if (sendClicked) {
          messageId = null;
        }
      });
    }
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    log('channel:${widget.channel}');
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Color(0xFF553370),
      body: Container(
        // padding: EdgeInsets.only(top: 60.0),
        child: Stack(
          children: [
            Container(
              // margin: EdgeInsets.only(top: 50.0),
              width: MediaQuery.of(context).size.width,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: chatMessage(),
            ),
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
                              addMessage(true);
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
                    onPressed: Get.back,
                    icon: Image.asset('assets/images/ic_chevron_left.png',
                        height: 20, width: 20, color: Colors.black),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      // border: Border.all(color: (user?.online ?? false) ? LimeColors.primaryColor : const Color(0xffd8d8d8), width: size > 40 ? 3 : 1.5),
                    ),
                    width: 50,
                    height: 50,
                    child: myProfilePic != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            imageUrl: myProfilePic!,
                            // placeholder: (context, url) => _textAvatar(text: LimeChatHelper.getChannelName(channel!)),
                            // errorWidget: (context, url, e) => _textAvatar(
                            //   text: LimeChatHelper.getChannelName(channel!),
                            // ),
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
                        // style: ,
                      ),
                      Text(
                        widget.username,
                        //  LimeChatHelper.getChannelUserNumber(channel),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        //   style: ,
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
                        onPressed: () {
                          //_startCallScreen(1);
                          Get.to(Video_call_screen(
                              widget.channel, myUserName!, widget.username));
                        },
                        shape: const CircleBorder(),
                        child: Image.asset("assets/images/ic_chat_video.png",
                            color: Get.theme.colorScheme.secondary,
                            width: 20,
                            height: 20),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 24,
                    child: RawMaterialButton(
                      onPressed: () {
                        //Get.to(StreamChannel(channel: widget.channel, child: const ChannelInfoScreen()));
                      },
                      shape: const CircleBorder(),
                      child: Image.asset("assets/images/ic_chat_more.png",
                          color: Get.theme.colorScheme.secondary,
                          width: 20,
                          height: 20),
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
}
