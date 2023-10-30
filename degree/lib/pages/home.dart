import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/pages/call_history_screen.dart';
import 'package:degree/pages/chat_main_screen.dart';
import 'package:degree/service/Controller.dart';
import 'package:degree/service/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DataController _dataController = Get.find();

  StreamSubscription? chatRoomListSubscription;
  Stream<QuerySnapshot<Object?>>? chatRoomsStream;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    if (chatRoomsStream != null)
      chatRoomListSubscription =
          chatRoomsStream!.asBroadcastStream().listen((e) {
        _dataController.chatroomsLength();
        var list = e.docs.map((e) {
          return e['to_msg_${_dataController.myusername}'];
        }).toList();
        if (!list.isEmpty || !(list.length == 0))
          _dataController.unreadChats.value =
              list.reduce((value, element) => value + element);
      });
  }

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
          icon: Obx(() {
            return Stack(
              children: [
                InkWell(
                  // onTap: () {},
                  child: Image.asset(
                    'assets/images/ic_chat1.png',
                    width: 50,
                    height: 30,
                    color: bottomSelectedIndex != 0
                        ? Color(0xff7C7C82A6).withOpacity(0.65)
                        : Color(0xff2675EC),
                  ),
                ),
                if (_dataController.unreadChats.value > 0) ...[
                  Positioned(
                      top: 0,
                      right: 5,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Text(
                          '${_dataController.unreadChats.value}',
                          style:
                              TextStyle(fontSize: 8, color: Color(0xffFEFFFE)),
                        ),
                      )),
                ],
              ],
            );
          }),
          label: 'Chats'),
      // BottomNavigationBarItem(
      //     icon: new Icon(Icons.missed_video_call), label: 'Calls'),
      BottomNavigationBarItem(
          icon: new Icon(Icons.missed_video_call), label: 'Calls'),
    ];
  }

  int bottomSelectedIndex = 0;

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: <Widget>[
        Chat_main_screen(),
        Call_history_screen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(''),
        // ),
        body: buildPageView(),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Color(0xff545458A6).withOpacity(0.65),
            border: Border(
              top: BorderSide(color: Color(0xffF6F6F6)),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Color(0xffF6F6F6),
            currentIndex: bottomSelectedIndex,
            items: buildBottomNavBarItems(),
            onTap: (index) {
              bottomTapped(index);
            },
            selectedItemColor: Color(0xff007AFF),
          ),
        ));

    // bottomNavigationBar: BottomAppBar(
    //     padding: EdgeInsets.symmetric(),
    //     height: 60,
    //     surfaceTintColor: Colors.white,
    //     color: Colors.white,
    //     child: Container(
    //       width: double.infinity,
    //       decoration: BoxDecoration(
    //         border: Border(top: BorderSide(color: Colors.black, width: 1)),
    //       ),
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
    //         children: [
    //           InkWell(
    //             onTap: () {
    //               Get.to(Call_history_screen());
    //             },
    //             child: Image.asset(
    //               'assets/images/ic_call.png',
    //               width: 80,
    //               height: 80,
    //             ),
    //           ),
    //           Obx(() {
    //             return Stack(
    //               children: [
    //                 InkWell(
    //                   onTap: () {},
    //                   child: Image.asset(
    //                     'assets/images/ic_chat.png',
    //                     width: 80,
    //                     height: 80,
    //                     color: Color(0xff007AFF),
    //                   ),
    //                 ),
    //                 if (_dataController.unreadChats.value > 0) ...[
    //                   Positioned(
    //                       top: 5,
    //                       //left: 10,
    //                       right: 20,
    //                       child: Container(
    //                         padding: EdgeInsets.symmetric(
    //                             horizontal: 5, vertical: 1),
    //                         decoration: BoxDecoration(
    //                             color: Colors.red,
    //                             borderRadius:
    //                                 BorderRadius.all(Radius.circular(10))),
    //                         child: Text(
    //                           '${_dataController.unreadChats.value}',
    //                           style: TextStyle(
    //                               fontSize: 8, color: Color(0xffFEFFFE)),
    //                         ),
    //                       )),
    //                 ],
    //               ],
    //             );
    //           }),
    //         ],
    //       ),
    //     )),
  }

  @override
  void dispose() {
    // _dataController.activeChatroomListeners.forEach((element) {
    //   _dataController.NewMessages[element]!.cancel();

    //   print('offline $element');
    //   Map<String, dynamic> lastMessageInfoMap = {
    //     "online": false,
    //   };
    //   DatabaseMethods().updateLastMessageSend(element, lastMessageInfoMap);
    // });
    super.dispose();
  }
}
