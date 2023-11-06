import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/service/controller.dart';
import 'package:degree/service/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class HistoryListScreen extends StatefulWidget {
  final calls, isAll;
  const HistoryListScreen({super.key, this.calls, this.isAll});

  @override
  State<HistoryListScreen> createState() => _HistoryListScreen();
}

class _HistoryListScreen extends State<HistoryListScreen> {
  final DataController _dataController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomRefreshIndicator(
          builder: (context, child, controller) => child,
          onRefresh: () async {
            _dataController.audioMessages.clear();
            _dataController.missedMessages.clear();
            _dataController.getCallHistories();
          },
          child: widget.calls.length != 0
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  //decoration: BoxDecoration(border: Border.all()),
                  width: double.infinity,
                  height: double.infinity,
                  child: ListView.builder(
                    itemCount: widget.calls.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ChatRoomListTile(
                          chatRoomId: widget.calls[index].channel,
                          userName: widget.calls[index].chatuserName,
                          read: false,
                          time: widget.calls[index].officialTime,
                          callStatus: widget.calls[index].callStatus);
                    },
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No Recents',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w500)),
                    const SizedBox(
                      height: 15,
                    ),
                    SvgPicture.asset(
                      _getAssetPath(widget.isAll ? 'outbound' : 'missed'),
                      height: 22,
                      width: 22,
                    ),
                  ],
                )),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final chatRoomId, userName, time, callStatus;

  final bool read;
  const ChatRoomListTile(
      {super.key,
      required this.chatRoomId,
      required this.userName,
      required this.read,
      required this.time,
      required this.callStatus});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String picUrl = "", name = "", id = "";
  List<String> userNativeLans = [];

  getthisUserInfo() async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(widget.userName);
    final user = querySnapshot.docs[0].data() as Map<String, dynamic>;
    name = "${user["Name"]}";
    picUrl = "${user["Photo"]}";
    id = "${user["Id"]}";
    userNativeLans = List<String>.from(user["native_lans"]);
    log('username: ${widget.userName}, picUrl: $picUrl, name: $name');
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
            onTap: () async {},
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xffBEBEBE),
                    width: 0.5,
                  ),
                ),
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
                        picUrl == ""
                            ? const CircularProgressIndicator()
                            : Container(
                                height: 55,
                                width: 55,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                fontFamily: "Nunito",
                                color: Colors.black,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w400,
                                height: 22 / 17,
                              ),
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  _getAssetPath(widget.callStatus),
                                  height: 18,
                                  width: 18,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  widget.callStatus,
                                  style: TextStyle(
                                    fontFamily: "Rubik",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: widget.callStatus == 'missed'
                                        ? Colors.red
                                        : const Color(0xff8e8e93),
                                    height: 17 / 14,
                                  ),
                                  textAlign: TextAlign.left,
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        //8-13
                        Text(
                          textAlign: TextAlign.end,
                          '${widget.time.month}'
                          " сарын "
                          '${widget.time.day}'
                          "\n"
                          '${widget.time.hour}'
                          ':'
                          '${widget.time.minute}',
                          style: const TextStyle(
                              fontFamily: "Nunito",
                              color: Colors.black45,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
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
