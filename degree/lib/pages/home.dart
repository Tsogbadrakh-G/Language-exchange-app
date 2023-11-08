import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/pages/call_history_screen.dart';
import 'package:degree/pages/chat_main_screen.dart';
import 'package:degree/service/controller.dart';
import 'package:degree/service/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final DataController _dataController = Get.find();

  StreamSubscription? chatRoomListSubscription;
  Stream<QuerySnapshot<Object?>>? chatRoomsStream;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    load();
    setStatus('online');
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> setStatus(String status) async {
    await usersCollection.doc(_dataController.id).update({'status': status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus('online');
    } else {
      setStatus('offline');
    }
  }

  Future<void> load() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    if (chatRoomsStream != null) {
      chatRoomListSubscription =
          chatRoomsStream!.asBroadcastStream().listen((e) {
        _dataController.chatroomsLength();
        var list = e.docs.map((e) {
          return e['to_msg_${_dataController.myusername}'];
        }).toList();
        if (list.isNotEmpty) {
          _dataController.unreadChats.value =
              list.reduce((value, element) => value + element);
        }
      });
    }
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
                        ? const Color(0xff7c7c82a6).withOpacity(0.65)
                        : const Color(0xff2675EC),
                  ),
                ),
                if (_dataController.unreadChats.value > 0) ...[
                  Positioned(
                      top: 0,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Text(
                          '${_dataController.unreadChats.value}',
                          style: const TextStyle(
                              fontSize: 8, color: Color(0xffFEFFFE)),
                        ),
                      )),
                ],
              ],
            );
          }),
          label: 'Chats'),
      BottomNavigationBarItem(
          icon: Stack(
            children: [
              InkWell(
                child: Image.asset(
                  'assets/images/ic_video.png',
                  width: 30,
                  height: 30,
                  color: bottomSelectedIndex != 1
                      ? const Color(0xff7c7c82a6).withOpacity(0.65)
                      : const Color(0xff2675EC),
                ),
              ),
              if (0 > 0) ...[
                Positioned(
                    top: 0,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: const Text(
                        '',
                        style: TextStyle(fontSize: 8, color: Color(0xffFEFFFE)),
                      ),
                    )),
              ],
            ],
          ),
          label: 'Calls'),
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
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: const <Widget>[
        ChatMainScreen(),
        CallHistoryScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          print('app paused');
          return true;
        },
        child: Scaffold(
            body: buildPageView(),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: const Color(0xff545458a6).withOpacity(0.65),
                border: const Border(
                  top: BorderSide(color: Color(0xffF6F6F6)),
                ),
              ),
              child: BottomNavigationBar(
                backgroundColor: const Color(0xffF6F6F6),
                currentIndex: bottomSelectedIndex,
                items: buildBottomNavBarItems(),
                onTap: (index) {
                  bottomTapped(index);
                },
                selectedItemColor: const Color(0xff007AFF),
              ),
            )));
  }

  @override
  void dispose() {
    print('disposing home screen');
    super.dispose();
  }
}
