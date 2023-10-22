import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/pages/home.dart';
import 'package:degree/pages/login.dart';
import 'package:degree/pages/select_languages.dart';
import 'package:degree/service/Controller.dart';
import 'package:degree/service/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Call_history_screen extends StatefulWidget {
  const Call_history_screen({Key? key}) : super(key: key);

  @override
  State<Call_history_screen> createState() => _Call_history_screen();
}

class _Call_history_screen extends State<Call_history_screen> {
  DataController _dataController = Get.find();
  final firestoreInstance = FirebaseFirestore.instance;
  String myUserName = '';
  List<String> chatRoomIds = [];
  @override
  void initState() {
    print('init call history');
    super.initState();
    myUserName = _dataController.myusername;
    getChatRoomIds();
  }

  List<Map<String, String>> chatMessages = List.empty(growable: true);
  List<Map<String, String>> audioMessages = List.empty(growable: true);

  void getChatRoomIds() async {
    QuerySnapshot querySnapshot =
        await firestoreInstance.collection('chatrooms').get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      chatRoomIds.add(doc.id);
      String username = doc.id.replaceAll(myUserName, "");
      username = username.replaceAll("_", "");
      log('user name: $username');
      QuerySnapshot chatSnapshot = await firestoreInstance
          .collection('chatrooms')
          .doc(doc.id)
          .collection('chats')
          .get();
      // chatMessages = chatSnapshot.docs.where((element) => )
      chatMessages = chatSnapshot.docs.map((chatDoc) {
        Map<String, dynamic> val = chatDoc.data() as Map<String, dynamic>;
        Map<String, String> ret = Map();
        ret['message'] = val['message'].toString();
        ret['type'] = val['type'].toString();
        ret['chatroomId'] = doc.id;
        ret['username'] = username;
        ret['type'] == 'audio' ? audioMessages.add(ret) : null;
        return ret;
      }).toList();
      print('chats $chatMessages in chatroom with ${doc.id}');
    }

    setState(() {}); // Notify Flutter to rebuild the UI with the chat room IDs.
  }

  getthisUserInfo(String username) async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());

    String profilePicUrl = querySnapshot.docs[0]['Photo'];
    log('profile url: $profilePicUrl');
    // user_native_lans = List<String>.from(querySnapshot.docs[0]["native_lans"]);
    //String key = chatroomId + myUserName!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text(
          "Дуудлагын түүх",
          style: TextStyle(
              color: Color(0Xff2675EC),
              fontSize: 22.0,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(border: Border.all()),
        width: double.infinity,
        height: double.infinity,
        child: ListView.builder(
          itemCount: chatMessages.length,
          itemBuilder: (BuildContext context, int index) {
            return ChatRoomListTile(
              chatRoomId: chatMessages[index]['chatRoomId'] ?? 'GTSOG321_TEST1',
              myUsername: _dataController.myusername,
              name: _dataController.myname,
              read: false,
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                Get.to(Call_history_screen());
              },
              child: Image.asset('assets/images/ic_call.png',
                  width: 80, height: 80, color: Color(0xff007AFF)),
            ),
            InkWell(
              onTap: () {
                Get.to(Home());
              },
              child: Image.asset(
                'assets/images/ic_chat.png',
                width: 80,
                height: 80,
              ),
            ),
            InkWell(
              onTap: () {},
              child: Image.asset(
                'assets/images/ic_setting.png',
                width: 70,
                height: 70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String chatRoomId, myUsername, name;

  final bool read;
  ChatRoomListTile({
    required this.chatRoomId,
    required this.myUsername,
    required this.name,
    required this.read,
  });

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
    name = "${querySnapshot.docs[0]["Name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["Photo"]}";
    id = "${querySnapshot.docs[0]["Id"]}";
    user_native_lans = List<String>.from(querySnapshot.docs[0]["native_lans"]);

    String key = widget.chatRoomId + widget.myUsername;
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
              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                  //border: Border.all(),
                  color: Color.fromARGB(255, 225, 222, 222),
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
                        'd',
                        // widget.time,
                        style: TextStyle(
                            color: Colors.black45,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  )
                ],
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
        padding: const EdgeInsets.only(bottom: 25),
        child: Row(
          children: [
            Icon(
              icon,
              color: Color(0xff2675ec),
              size: 40,
            ),
            const SizedBox(
              width: 40,
            ),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                    fontFamily: "Gilroy",
                    fontSize: 19,
                    fontWeight: FontWeight.w400,
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
