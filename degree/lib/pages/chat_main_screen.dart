import 'package:degree/pages/chat_room.dart';
import 'package:degree/service/Controller.dart';
import 'package:degree/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/DataAPI.dart';
import 'package:degree/service/model/Customer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'chatpage.dart';
import '../service/database.dart';

class Chat_main_screen extends StatefulWidget {
  const Chat_main_screen({Key? key}) : super(key: key);

  @override
  State<Chat_main_screen> createState() => _Chat_main_screen();
}

class _Chat_main_screen extends State<Chat_main_screen> {
  DataController _dataController = Get.find();
  Helper _helperController = Get.find();
  bool search = false;
  // String? myName, myProfilePic, myUserName, myEmail, myId;
  Stream<QuerySnapshot<Object?>>? chatRoomsStream;
  PageController controller = PageController();
  StreamSubscription<Map<String, dynamic>>? lastMessageStream;
  StreamSubscription? chatRoomListSubscription;
  FocusNode _focusNode = FocusNode();
  TextEditingController textEditingController = TextEditingController();
  RxBool menu = true.obs;

  @override
  void initState() {
    ontheload();
    _focusNode.addListener(_handleFocusChange);
    _dataController.chatroomsLength();
    print('init chat main screen');
    super.initState();
  }

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
    print('qset: $queryResultSet');
    var capitalizedValue = value.substring(0, 1).toUpperCase();
    if (queryResultSet.isEmpty && value.length == 1) {
      print('search in DataStore');
      DatabaseMethods().Search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['username'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  getChannels() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  ontheload() async {
    getChannels();
    print('chat room ${chatRoomsStream}');
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

    [Permission.microphone, Permission.camera, Permission.photos].request();
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

  ListenRoom(String channel) async {
    String username =
        channel.replaceAll("_", "").replaceAll(_dataController.myusername, "");
    username = username.replaceAll("_", "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    user_native_lans = List<String>.from(querySnapshot.docs[0]["native_lans"]);

    if (!_dataController.activeChatroomListeners.contains(channel)) {
      print('update last message with ${channel}');
      _dataController.activeChatroomListeners.add(channel);
      _dataController.listenForNewMessages(
          channel, username, user_native_lans, context);
    }
  }

  Widget ChatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return Text('No Data Available');
          } else {
            return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      String username = ds.id
                          .replaceAll("_", "")
                          .replaceAll(_dataController.myusername, "");
                      _dataController.checkToLastMessage(
                          ds.id,
                          _dataController.myusername,
                          username,
                          ds["read"],
                          ds["lastMessageSendBy"],
                          ds.data() as Map<String, dynamic>);
                      ListenRoom(ds.id);

                      log('room id ${ds.id}');

                      return ChatRoomListTile(
                        chatRoomId: ds.id,
                        lastMessage: ds["lastMessage"],
                        myUsername: _dataController.myusername,
                        sendBy: ds["lastMessageSendBy"],
                        time: ds["lastMessageSendTs"],
                        read: ds["read"],
                        to_msg_num: ds['to_msg_${_dataController.myusername}'],
                        name: ds['sendByNameFrom'] == _dataController.myname
                            ? ds['sendByNameTo']
                            : ds['sendByNameFrom'],
                      );
                    }));
          }
        });
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      search = true;
    } else {
      search = false;
    }
    setState(() {});
  }

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  PreferredSizeWidget HomeAppbar() {
    return AppBar(
      elevation: 0.5,
      automaticallyImplyLeading: false,
      toolbarHeight: 52,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Container(
//          decoration: BoxDecoration(border: Border.all()),
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, top: 18.0, bottom: 0.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding: EdgeInsets.all(2),
                      child: GestureDetector(
                        onTap: () {
                          _globalKey.currentState!.openDrawer();
                        },
                        child: Image.asset(
                          'assets/images/img_menu.png',
                          width: 30,
                          height: 20,
                        ),
                      )),
                  Text(
                    "ChatUp",
                    style: const TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff2675ec),
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    textEditingController.value = textEditingController.value.copyWith(
      // Set the cursor position at the end
      selection:
          TextSelection.collapsed(offset: textEditingController.text.length),
    );
    return Scaffold(
        backgroundColor: Colors.white,
        key: _globalKey,
        appBar: HomeAppbar(),
        drawer:
            _helperController.drawerBuilder(_dataController.myname, context),
        body: CustomScrollView(slivers: [
          SliverAppBar(
            elevation: 0,
            floating: true,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: Container(
              // height: 35,
              decoration: BoxDecoration(
                  //color: Colors.white,
                  // borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextField(
                cursorHeight: 25,
                controller: textEditingController,
                textAlignVertical: TextAlignVertical.center,
                focusNode: _focusNode,
                textAlign: search ? TextAlign.start : TextAlign.center,
                autocorrect: true,
                textCapitalization: TextCapitalization.words,
                onChanged: (value) {
                  initiateSearch(value.toUpperCase());
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xff0000000D).withOpacity(0.05),
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  suffixIcon: IconButton(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    icon: search
                        ? GestureDetector(
                            onTap: () {
                              textEditingController.clear();
                              FocusScope.of(context).requestFocus(FocusNode());

                              search = false;

                              tempSearchStore = [];
                              print('search');
                              getChannels();

                              //setState(() {});
                            },
                            child: Icon(
                              size: 25,
                              Icons.close,
                              color: Color(0Xff2675EC),
                            ))
                        : GestureDetector(
                            onTap: () {
                              search = true;
                              _focusNode.requestFocus();
                              print('not search');
                              setState(() {});
                            },
                            child: Icon(
                              size: 30,
                              Icons.search,
                              color: Color(0Xff2675EC),
                            ),
                          ),
                    onPressed: () {
                      search = true;
                      setState(() {});
                    },
                  ),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 205, 205, 206),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 205, 205,
                          206), // Set the border color when focused
                    ),
                  ),
                  hintText: 'Хайх',
                  hintStyle: TextStyle(
                    fontFamily: "Manrope",
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff3c3c43).withOpacity(0.5),
                    //height: 22 / 17,
                  ),
                ),
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    fontFamily: 'Nunito',
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
          Obx(() {
            if (_dataController.roomsLen == 0 && search == false)
              return SliverToBoxAdapter(
                child: Container(
                    height: MediaQuery.sizeOf(context).height * 2 / 3,
                    // decoration: BoxDecoration(border: Border.all()),
                    child: Center(
                        child: Text(
                      'No item',
                      style: TextStyle(fontFamily: 'Nunito'),
                    ))),
              );
            else
              return SliverPadding(
                padding: EdgeInsets.only(top: 5),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // Build the list of items

                      return search
                          ? ListView(
                              padding: EdgeInsets.only(left: 5.0, right: 5.0),
                              primary: false,
                              shrinkWrap: true,
                              children: [...tempSearchStore].map((element) {
                                return buildResultCard(element);
                              }).toList())
                          : ChatRoomList();
                    },
                    childCount: 1, // Number of items in the list
                  ),
                ),
              );
          }),
        ]));
  }

  List<String> user_native_lans = [];
  getthisUserInfo(String username, String usrId, String chatroomId) async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());

    user_native_lans = List<String>.from(querySnapshot.docs[0]["native_lans"]);
    String key = chatroomId + _dataController.myusername;

    // if (usersBox.get(key) != null)
    // print(
    //     'user  selected lans $usrId: ${usersBox.get(key)!.trans_from_voice}');
    if (usersBox.get(key) == null) {
      //   print('user: $usrId is null');
      usersBox.put(
          chatroomId,
          Customer(
            id: usrId,
            trans_from_voice: 'Halh Mongolian',
            trans_to_voice: user_native_lans[0],
            trans_from_msg: 'Halh Mongolian',
            trans_to_msg: user_native_lans[0],
          ));
    }
  }

  Widget buildResultCard(data) {
    var chatRoomId =
        getChatRoomIdbyUsername(_dataController.myusername, data["username"]);
    return FutureBuilder(
        future: getthisUserInfo(data["username"], data['Id'], chatRoomId),
        builder: (context, snapshot) {
          return GestureDetector(
            onTap: () async {
              search = false;

              Map<String, dynamic> chatRoomInfoMap = {
                "users": [_dataController.myusername, data["username"]],
              };

              print('created channel: $chatRoomId');
              await DatabaseMethods()
                  .createChatRoom(chatRoomId, chatRoomInfoMap);

              if (!_dataController.activeChatroomListeners
                  .contains(chatRoomId)) {
                _dataController.listenForNewMessages(
                    chatRoomId, data["username"], user_native_lans, context);
              }

              await Get.to(
                  ChatPage(
                    userId: data['Id'],
                    name: data["Name"],
                    profileurl: data["Photo"],
                    username: data["username"],
                    channel: chatRoomId,
                  ),
                  arguments: user_native_lans);
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            data["Photo"],
                            height: 60,
                            width: 60,
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
                                color: Color(0xff434347),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Nunito',
                                fontSize: 18.0),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            data["username"],
                            style: TextStyle(
                                color: Color(0xff434347),
                                fontSize: 15.0,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
