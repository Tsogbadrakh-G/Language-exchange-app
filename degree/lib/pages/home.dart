import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/Video_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chatpage.dart';
import '../service/database.dart';
import '../service/shared_pref.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  String? myName, myProfilePic, myUserName, myEmail;
  Stream? chatRoomsStream;
  PageController controller = PageController();
  int _curr = 0;

  getthesharedpref() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserPic();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  Widget ChatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    print(ds.id);
                    return ChatRoomListTile(
                        chatRoomId: ds.id,
                        lastMessage: ds["lastMessage"],
                        myUsername: myUserName!,
                        time: ds["lastMessageSendTs"]);
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

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

  var queryResultSet = [];
  var tempSearchStore = [];
//should search via mail
  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        log('null');
        queryResultSet = [];
        tempSearchStore = [];
      });
      return;
    }
    setState(() {
      search = true;
    });
    log('qset: $queryResultSet');
    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.isEmpty && value.length == 1) {
      log('search in DataStore');
      DatabaseMethods().Search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        log('search in local');
        if (element['username'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      drawer: Drawer(
        width: 275,
        elevation: 30,
        backgroundColor: Color(0xF3393838),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(40))),
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                    color: Color(0x3D000000), spreadRadius: 30, blurRadius: 20)
              ]),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 56,
                        ),
                        Text(
                          'Settings',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        UserAvatar(filename: myProfilePic ?? ''),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          'Tom Brenan',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    const DrawerItem(
                      title: 'Account',
                      icon: Icons.key,
                    ),
                    const DrawerItem(title: 'Chats', icon: Icons.chat_bubble),
                    const DrawerItem(
                        title: 'Notifications', icon: Icons.notifications),
                    const DrawerItem(
                        title: 'Data and Storage', icon: Icons.storage),
                    const DrawerItem(title: 'Help', icon: Icons.help),
                    const Divider(
                      height: 35,
                      color: Colors.green,
                    ),
                    const DrawerItem(
                        title: 'Invite a friend', icon: Icons.people_outline),
                  ],
                ),
                const DrawerItem(title: 'Log out', icon: Icons.logout)
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        allowImplicitScrolling: true,
        scrollDirection: Axis.horizontal,
        controller: controller,
        onPageChanged: (num) {
          setState(() {
            _curr = num;
            log('$num');
          });
        },
        children: [
          if (_curr == 0)
            Container(
                color: Colors.white,
                child: Column(children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                        color: Colors.black,
                      )),
                    ),
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 50.0, bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _globalKey.currentState!.openDrawer();
                          },
                          child: Image.asset(
                            'assets/images/img_menu.png',
                            width: 25,
                            height: 25,
                          ),
                        ),
                        search
                            ? Expanded(
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  onChanged: (value) {
                                    log('$value');
                                    initiateSearch(value.toUpperCase());
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Search User',
                                      hintStyle: TextStyle(
                                          color: Color(0Xff2675EC),
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w500)),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            : Text(
                                "ChatUp",
                                style: TextStyle(
                                    color: Color(0Xff2675EC),
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold),
                              ),
                        GestureDetector(
                          onTap: () {
                            search = true;
                            setState(() {});
                          },
                          child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: search
                                  ? GestureDetector(
                                      onTap: () {
                                        search = false;
                                        queryResultSet = [];
                                        tempSearchStore = [];

                                        setState(() {});
                                      },
                                      child: Icon(
                                        size: 35,
                                        Icons.close,
                                        color: Color(0Xff2675EC),
                                      ),
                                    )
                                  : Icon(
                                      size: 35,
                                      Icons.search,
                                      color: Color(0Xff2675EC),
                                    )),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 10),
                      children: [
                        TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Messages",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 26),
                            )),
                        const SizedBox(
                          width: 35,
                        ),
                        TextButton(
                            onPressed: () {
                              _curr = 1;
                              setState(() {});
                            },
                            child: const Text(
                              "Online",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 26),
                            )),
                        const SizedBox(
                          width: 35,
                        ),
                        TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Groups",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 26),
                            )),
                        const SizedBox(
                          width: 35,
                        ),
                        TextButton(
                            onPressed: () {},
                            child: const Text(
                              "More",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 26),
                            )),
                        const SizedBox(
                          width: 35,
                        ),
                      ],
                    ),
                  ),
                  // Expanded(
                  //   child: Container(
                  //     padding:
                  //         EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                  //     width: double.infinity,
                  //     height: double.infinity,
                  //     // width: MediaQuery.of(context).size.width,
                  //     // height: search
                  //     //     ? MediaQuery.of(context).size.height / 1.19
                  //     //     : MediaQuery.of(context).size.height / 1.15,
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       // borderRadius: BorderRadius.only(
                  //       //     topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  //     ),
                  //     child: Column(
                  //       children: [
                  //   search
                  //              ? ListView(
                  //                 padding:
                  //                     EdgeInsets.only(left: 10.0, right: 10.0),
                  //                 primary: false,
                  //                 shrinkWrap: true,
                  //                 children: tempSearchStore.map((element) {
                  //                   return buildResultCard(element);
                  //                 }).toList())
                  //             : ChatRoomList(),
                  //       ],
                  //     ),
                  //    ),

                  // ),
                  Expanded(
                      child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                    width: double.infinity,
                    height: double.infinity,
                    child: search
                        ? ListView(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            primary: false,
                            shrinkWrap: true,
                            children: tempSearchStore.map((element) {
                              return buildResultCard(element);
                            }).toList())
                        : ChatRoomList(),
                  ))
                ])),
          if (_curr == 1)
            Center(
                child: Pages(
              text: "Page Two",
              color: Colors.red.shade100,
            )),
          if (_curr == 2)
            Center(
                child: Pages(
              text: "Page Three",
              color: Colors.grey,
            )),
          if (_curr == 3)
            Center(
                child: Pages(
              text: "Page Four",
              color: Colors.yellow.shade100,
            ))
        ],
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        search = false;

        var chatRoomId = getChatRoomIdbyUsername(myUserName!, data["username"]);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, data["username"]],
        };

        await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        setState(() {});
        Get.to(ChatPage(
          name: data["Name"],
          profileurl: data["Photo"],
          username: data["username"],
          channel: chatRoomId,
        ));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      data["Photo"],
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    )),
                SizedBox(
                  width: 20.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["Name"],
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      data["username"],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, time;
  ChatRoomListTile(
      {required this.chatRoomId,
      required this.lastMessage,
      required this.myUsername,
      required this.time});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "", id = "";

  getthisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUsername, "");
    print(username);
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    name = "${querySnapshot.docs[0]["Name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["Photo"]}";
    id = "${querySnapshot.docs[0]["Id"]}";
    setState(() {});
  }

  @override
  void initState() {
    getthisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log('username: $username');
    return GestureDetector(
      onTap: () {
        log('to ${widget.chatRoomId}');
        Get.to(ChatPage(
          name: name,
          profileurl: profilePicUrl,
          username: username,
          channel: widget.chatRoomId,
        ));
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            profilePicUrl == ""
                ? CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      profilePicUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )),
            SizedBox(
              width: 10.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  username,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w500),
                ),
                Container(
                  child: Text(
                    widget.lastMessage,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: true ? Color(0xff848484) : Color(0xff2675EC),
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Spacer(),
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
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  const DrawerItem({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(
              width: 40,
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
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
