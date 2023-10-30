import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/DataAPI.dart';
import 'package:degree/pages/chatpage.dart';
import 'package:degree/service/database.dart';
import 'package:degree/service/model/Customer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, time, sendBy, name;
  final int to_msg_num;
  final bool read;
  ChatRoomListTile(
      {required this.chatRoomId,
      required this.lastMessage,
      required this.myUsername,
      required this.time,
      required this.sendBy,
      required this.name,
      required this.read,
      required this.to_msg_num});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "", id = "";
  List<String> user_native_lans = [];
  getthisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUsername, "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    user_native_lans = List<String>.from(querySnapshot.docs[0]["native_lans"]);
    name = "${querySnapshot.docs[0]["Name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["Photo"]}";
    id = "${querySnapshot.docs[0]["Id"]}";

    String key = widget.chatRoomId + widget.myUsername;

    if (usersBox.get(key) != null) {
      // print('user  selected lans ${widget.chatRoomId} ');
      // print(
      //     'from msg: ${usersBox.get(key)!.trans_from_msg}, to msg:${usersBox.get(key)!.trans_to_msg},  ');
      // print(
      //     'from voice: ${usersBox.get(key)!.trans_from_voice}, to voice:${usersBox.get(key)!.trans_to_voice}');
    } else {
      //   print('user: ${widget.chatRoomId} is null');
      usersBox.put(
          key,
          Customer(
            id: widget.chatRoomId,
            trans_from_voice: 'Halh Mongolian',
            trans_to_voice: user_native_lans[0],
            trans_from_msg: 'Halh Mongolian',
            trans_to_msg: user_native_lans[0],
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
          return Slidable(
            key: Key(widget.chatRoomId),
            useTextDirection: false,
            // reminders.remove(reminders[index]);

            endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.3,
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      DatabaseMethods().deleteChatroom(widget.chatRoomId);
                      // LimeAlerts.alertBox(
                      //   imgAsset: 'alert/alert_default_info',
                      //   text: 'alert_del'.tr,
                      //   onOkTitle: 'delete'.tr,
                      //   onNoTitle: 'cancel'.tr,
                      //   onOk: () {
                      //     Reminders.removeReminder(reminders[index]);
                      //     Get.back();
                      //     setState(() {});
                      //   },
                      //   onNo: Get.back,
                      // );
                    },
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    backgroundColor: Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: CupertinoIcons.delete,
                    label: 'delete',
                  ),
                ]),
            child: GestureDetector(
              onTap: () async {
                print('click to ${widget.chatRoomId}');
                await Get.to(
                    ChatPage(
                      userId: id,
                      name: name,
                      profileurl: profilePicUrl,
                      username: username,
                      channel: widget.chatRoomId,
                    ),
                    arguments: user_native_lans);

                setState(() {});
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    // border: Border(
                    //   bottom: BorderSide(
                    //     color: Color(0xffBEBEBE),
                    //     width: 0.5,
                    //   ),
                    // ),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    profilePicUrl == ""
                        ? CircularProgressIndicator()
                        : Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.5)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                profilePicUrl,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    SizedBox(
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
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500),
                          ),
                          // const SizedBox(
                          //   height: 5,
                          // ),
                          Container(
                            child: Text(
                              widget.sendBy == widget.myUsername
                                  ? "you: " + widget.lastMessage
                                  : widget.lastMessage,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: widget.sendBy == widget.myUsername
                                    ? Color(0xff848484)
                                    : widget.read
                                        ? Color(0xff848484)
                                        : Color(0xff2675ec),
                                fontFamily: "Nunito",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.time,
                          style: TextStyle(
                              color: Colors.black45,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (widget.to_msg_num != 0) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7, vertical: 5),
                            decoration: BoxDecoration(
                                color: Color(0xff2675EC),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: Text(
                              '${widget.to_msg_num}',
                              style: const TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 15,
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
                            scale: 1.9,
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

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function() myFunction;
  DrawerItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.myFunction});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: myFunction,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25, left: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: Color(0xff2675ec),
              size: 30,
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                    fontFamily: "Manrope",
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff2675ec),
                    height: 23 / 19,
                  ),
                  textAlign: TextAlign.left),
            ),
          ],
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String filename;
  UserAvatar({
    super.key,
    required this.filename,
  });

  @override
  Widget build(BuildContext context) {
    if (filename != '')
      return CircleAvatar(
        radius: 32,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 29,
          backgroundImage: Image.network(filename).image,
        ),
      );
    else
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

class Pages extends StatelessWidget {
  final text;
  final color;
  Pages({this.text, this.color});
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
