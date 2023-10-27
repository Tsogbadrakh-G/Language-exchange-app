import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/service/Controller.dart';
import 'package:degree/service/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class History_list_screen extends StatefulWidget {
  final calls, isAll;
  const History_list_screen({this.calls, this.isAll});

  @override
  State<History_list_screen> createState() => _History_list_screen();
}

class _History_list_screen extends State<History_list_screen> {
  DataController _dataController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomRefreshIndicator(
        builder: (context, child, controller) => child,
        onRefresh: () async {
          _dataController.audioMessages.clear();
          _dataController.missedMessages.clear();
          _dataController.getChatRoomIds();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //decoration: BoxDecoration(border: Border.all()),
          width: double.infinity,
          height: double.infinity,
          child: ListView.builder(
            itemCount: widget.calls.length,
            itemBuilder: (BuildContext context, int index) {
              return ChatRoomListTile(
                  chatRoomId: widget.calls[index].channel,
                  myUsername: _dataController.myusername,
                  read: false,
                  time: widget.calls[index].time,
                  callStatus: widget.calls[index].callStatus);
            },
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String chatRoomId, myUsername, time, callStatus;

  final bool read;
  ChatRoomListTile(
      {required this.chatRoomId,
      required this.myUsername,
      required this.read,
      required this.time,
      required this.callStatus});

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
    final user = querySnapshot.docs[0].data() as Map<String, dynamic>;
    name = "${user["Name"]}";
    profilePicUrl = "${user["Photo"]}";
    id = "${user["Id"]}";
    user_native_lans = List<String>.from(user["native_lans"]);

    print('user info: ${user}');

    //String key = widget.chatRoomId + widget.myUsername;
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
          return GestureDetector(
            onTap: () async {
              setState(() {});
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xffBEBEBE),
                    width: 0.5,
                  ),
                ),
                //   color: Color.fromARGB(255, 225, 222, 222),
                // borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          _getAssetPath(widget.callStatus),
                          height: 18,
                          width: 18,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        profilePicUrl == ""
                            ? CircularProgressIndicator()
                            : Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.5)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    profilePicUrl,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: "Nunito",
                                color: Colors.black,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w400,
                                height: 22 / 17,
                              ),
                            ),
                            Text(
                              widget.callStatus,
                              style: const TextStyle(
                                fontFamily: "Rubik",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff8e8e93),
                                height: 17 / 14,
                              ),
                              textAlign: TextAlign.left,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   width: 30,
                  // ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        //8-13
                        Text(
                          textAlign: TextAlign.end,
                          widget.time.substring(8, 10) +
                              " сарын " +
                              widget.time.substring(8, 10) +
                              "\n" +
                              widget.time.substring(0, 6),
                          style: TextStyle(
                              fontFamily: "Nunito",
                              color: Colors.black45,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500),
                        ),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  String _getAssetPath(String type) {
    String ret = '';
    switch (type) {
      case 'missed':
        ret = 'assets/svg/missed_call.svg';
      case 'inbound':
        ret = 'assets/svg/inbound_call.svg';
      case 'outbound':
        ret = 'assets/svg/outbound_call.svg';
    }
    return ret;
  }
}
