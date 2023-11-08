import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/service/data_api.dart';
import 'package:degree/pages/chatpage.dart';
import 'package:degree/service/controller.dart';
import 'package:degree/service/database.dart';
import 'package:degree/models/customer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, time, sendBy, name;
  final int toMsgNum;
  final bool read;
  const ChatRoomListTile(
      {super.key,
      required this.chatRoomId,
      required this.lastMessage,
      required this.myUsername,
      required this.time,
      required this.sendBy,
      required this.name,
      required this.read,
      required this.toMsgNum});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String picUrl = "", name = "", username = "", id = "";
  List<String> userNativeLans = [];
  final DataController _dataController = Get.find();
  getthisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUsername, "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    userNativeLans = List<String>.from(querySnapshot.docs[0]["native_lans"]);
    name = "${querySnapshot.docs[0]["Name"]}";
    picUrl = "${querySnapshot.docs[0]["Photo"]}";
    id = "${querySnapshot.docs[0]["Id"]}";

    log('user name: $username, URL: $picUrl');

    String key = widget.chatRoomId + widget.myUsername;

    if (usersBox.get(key) != null) {
    } else {
      usersBox.put(
          key,
          Customer(
            id: widget.chatRoomId,
            transFromVoice: 'Halh Mongolian',
            transToVoice: userNativeLans[0],
            transFromMsg: 'Halh Mongolian',
            transToMsg: userNativeLans[0],
          ));
    }
  }

  @override
  void initState() {
    getthisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getthisUserInfo(),
        builder: (context, snapshot) {
          log('room build');
          return Slidable(
            key: Key(widget.chatRoomId),
            useTextDirection: false,
            endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.3,
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      if (_dataController.roomsLen > 0) {
                        _dataController.roomsLen--;
                      }
                      DatabaseMethods().deleteChatroom(widget.chatRoomId);
                    },
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    backgroundColor: const Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: CupertinoIcons.delete,
                    label: 'delete',
                  ),
                ]),
            child: InkWell(
              highlightColor: Colors.amberAccent,
              splashColor: Colors.red.shade100,
              onTap: () async {
                //   print('click to ${widget.chatRoomId}');
                await Get.to(
                    ChatPage(
                      userId: id,
                      name: name,
                      profileurl: picUrl,
                      username: username,
                      channel: widget.chatRoomId,
                    ),
                    arguments: userNativeLans);

                setState(() {});
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                    //border: Border.all(),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    picUrl == ""
                        ? const CircularProgressIndicator()
                        : Container(
                            height: 65,
                            width: 65,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.5)),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(30))),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: CachedNetworkImage(
                                imageUrl: picUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            widget.name,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            widget.sendBy == widget.myUsername
                                ? "you: ${widget.lastMessage}"
                                : widget.lastMessage,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: widget.sendBy == widget.myUsername
                                    ? const Color(0xff848484)
                                    : widget.read
                                        ? const Color(0xff848484)
                                        : const Color(0xff2675ec),
                                fontFamily: "Nunito",
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.time,
                          style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (widget.toMsgNum != 0) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 5),
                            decoration: const BoxDecoration(
                                color: Color(0xff2675EC),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: Text(
                              '${widget.toMsgNum}',
                              style: const TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: 13 / 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ] else if (widget.read &&
                            widget.sendBy == widget.myUsername)
                          Image.asset(
                            'assets/images/img_viewed.png',
                            scale: 2,
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class UserAvatar extends StatelessWidget {
  final String filename;
  const UserAvatar({
    super.key,
    required this.filename,
  });

  @override
  Widget build(BuildContext context) {
    if (filename != '') {
      return CircleAvatar(
        radius: 32,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 29,
          backgroundImage: Image.network(filename).image,
        ),
      );
    } else {
      return CircleAvatar(
        radius: 32,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 29,
          backgroundImage: Image.asset('assets/images/boy1.jpg').image,
        ),
      );
    }
  }
}

class Pages extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final text;
  // ignore: prefer_typing_uninitialized_variables
  final color;
  const Pages({super.key, this.text, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                text,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
              ),
            ]),
      ),
    );
  }
}
