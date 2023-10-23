import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/pages/home.dart';
import 'package:degree/service/Controller.dart';
import 'package:degree/service/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/Chat.dart';

class Call_history_screen extends StatefulWidget {
  const Call_history_screen({Key? key}) : super(key: key);

  @override
  State<Call_history_screen> createState() => _Call_history_screen();
}

class _Call_history_screen extends State<Call_history_screen> {
  DataController _dataController = Get.find();
  final firestoreInstance = FirebaseFirestore.instance;
  String myUserName = '';

  @override
  void initState() {
    print('init call history');
    myUserName = _dataController.myusername;
    getChatRoomIds();
    super.initState();
  }

  List<Chat> chatMessages = List.empty(growable: true);
  List<Chat> audioMessages = List.empty(growable: true);
  List<bool> readOrMissed = List.empty(growable: true);
  List<String> chaTime = List.empty(growable: true);

  void getChatRoomIds() async {
    QuerySnapshot querySnapshot =
        await firestoreInstance.collection('chatrooms').get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      String username = doc.id.replaceAll(myUserName, "");
      username = username.replaceAll("_", "");
      log('user name: $username');
      QuerySnapshot chatSnapshot = await firestoreInstance
          .collection('chatrooms')
          .doc(doc.id)
          .collection('chats')
          .get();

      //messages in doc.id chatroom
      chatMessages = chatSnapshot.docs.map((chatDoc) {
        Map<String, dynamic> val = chatDoc.data() as Map<String, dynamic>;
        Chat ret = Chat(
            id: val['id'].toString(),
            message: val['message'].toString(),
            chatuserName: val['sendBy'].toString(),
            callStatus: 'missed',
            time: val['ts'].toString(),
            channel: doc.id);

        if (val['type'] == 'audio') {
          audioMessages.add(ret);
        }
        print('time: ${ret.time}, val: $val in room id: ${doc.id}');
        return ret;
      }).toList();

      print('chats $chatMessages in chatroom with ${doc.id}');
      print('audio chats len : ${audioMessages.length}');
    }

    setState(() {}); // Notify Flutter to rebuild the UI with the chat room IDs.
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(border: Border.all()),
        width: double.infinity,
        height: double.infinity,
        child: ListView.builder(
          itemCount: audioMessages.length,
          itemBuilder: (BuildContext context, int index) {
            return ChatRoomListTile(
              chatRoomId: audioMessages[index].channel,
              myUsername: _dataController.myusername,
              read: false,
              time: audioMessages[index].time,
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
  final String chatRoomId, myUsername, time;

  final bool read;
  ChatRoomListTile(
      {required this.chatRoomId,
      required this.myUsername,
      required this.read,
      required this.time});

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

    print('user info: ${querySnapshot.docs[0]}');

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
                              height: 50,
                              width: 50,
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
                          name,
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
                  Expanded(
                    flex: 2,
                    child: Column(
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
