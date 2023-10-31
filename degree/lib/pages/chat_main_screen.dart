import 'package:degree/pages/chat_room.dart';
import 'package:degree/service/Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/DataAPI.dart';

import 'package:degree/pages/login.dart';

import 'package:degree/service/model/Customer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'chatpage.dart';
import '../service/database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:table_calendar/table_calendar.dart';

class Chat_main_screen extends StatefulWidget {
  const Chat_main_screen({Key? key}) : super(key: key);

  @override
  State<Chat_main_screen> createState() => _Chat_main_screen();
}

class _Chat_main_screen extends State<Chat_main_screen> {
  DataController _dataController = Get.find();
  bool search = false;
  String? myName, myProfilePic, myUserName, myEmail, myId;
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
    super.initState();
  }

  ontheload() async {
    await getthesharedpref();
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    log('chat room $chatRoomsStream');
    if (chatRoomsStream != null)
      chatRoomListSubscription =
          chatRoomsStream!.asBroadcastStream().listen((e) {
        _dataController.chatroomsLength();
        var list = e.docs.map((e) {
          return e['to_msg_$myUserName'];
        }).toList();
        if (!list.isEmpty || !(list.length == 0))
          _dataController.unreadChats.value =
              list.reduce((value, element) => value + element);
      });
    setState(() {});
    [Permission.microphone, Permission.camera, Permission.photos].request();
  }

  getthesharedpref() async {
    myUserName = _dataController.myusername;
    myName = _dataController.myname;
    myProfilePic = _dataController.picUrl.value;
    myEmail = _dataController.email;
    myId = _dataController.id;

    setState(() {});
  }

  ListenRoom(String channel) async {
    String username = channel.replaceAll("_", "").replaceAll(myUserName!, "");
    username = username.replaceAll("_", "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    user_native_lans = List<String>.from(querySnapshot.docs[0]["native_lans"]);

    if (!_dataController.activeChatroomListeners.contains(channel)) {
      print('update last message with ${channel}');
      _dataController.activeChatroomListeners.add(channel);
      _dataController.listenForNewMessages(channel, username, user_native_lans);
    }
  }

  Widget ChatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, AsyncSnapshot snapshot) {
          print('snapsot: ${snapshot.hasData}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('connection waiting');
            return Center(child: CircularProgressIndicator());
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
                      String username =
                          ds.id.replaceAll("_", "").replaceAll(myUserName!, "");
                      _dataController.CheckToLastMessage(
                          ds.id,
                          myUserName!,
                          username,
                          ds["read"],
                          ds["lastMessageSendBy"],
                          ds.data() as Map<String, dynamic>);
                      ListenRoom(ds.id);

                      log('room id ${ds.id}');

                      return ChatRoomListTile(
                        chatRoomId: ds.id,
                        lastMessage: ds["lastMessage"],
                        myUsername: myUserName!,
                        sendBy: ds["lastMessageSendBy"],
                        time: ds["lastMessageSendTs"],
                        read: ds["read"],
                        to_msg_num: ds['to_msg_$myUserName'],
                        name: ds['sendByNameFrom'] == myName
                            ? ds['sendByNameTo']
                            : ds['sendByNameFrom'],
                      );
                    }));
          }
        });
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
        print('search in local');
        if (element['username'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  void selectedImage() async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (_file == null) return;

    File img = File(_file.path);
    var time = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      await FirebaseStorage.instance.ref('$myUserName/$time.png').putFile(img);
    } catch (e) {
      print('upload image to firebase exception: $e');
    }

    myProfilePic = await FirebaseStorage.instance
        .ref('$myUserName/$time.png')
        .getDownloadURL();
    _dataController.picUrl.value = myProfilePic!;
    // await DefaultCacheManager().emptyCache();
    print('uploaded its url :$myProfilePic, userid: $myId');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId ?? _dataController.id)
        .update({"Photo": myProfilePic});
    setState(() {});
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      // TextField is currently active (has focus)

      search = true;
      //print('active textfield search: $search');
      setState(() {});
    } else {
      search = false;
      //print('inactive textfield search: $search');
      setState(() {});
      // TextField is currently inactive (doesn't have focus)
    }
  }

  Widget DrawerBuilder(String name) {
    // print('my profile in drawer: $myProfilePic');
    return Drawer(
      width: 300,
      elevation: 30,
      backgroundColor: Color(0xFfFFFFFF),
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(0))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Settings",
                        style: const TextStyle(
                          fontFamily: "Gilroy",
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff2675ec),
                          height: 27 / 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xff2675ec),
                          size: 25,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Stack(
                          children: [
                            myProfilePic == null
                                ? CircularProgressIndicator()
                                : GestureDetector(
                                    onLongPress: selectedImage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          border: Border.all(
                                              color: Colors.black
                                                  .withOpacity(0.5))),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Obx(() {
                                          return Image.network(
                                            _dataController.picUrl.value,
                                            fit: BoxFit.cover,
                                            height: 100,
                                            width: 100,
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontFamily: "Manrope",
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff2675ec),
                            height: 30 / 23,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  DrawerItem(
                    title: 'Хэрэглэгчийн булан',
                    icon: Icons.supervised_user_circle_outlined,
                    myFunction: () {},
                  ),
                  DrawerItem(
                    title: 'Тусламж',
                    icon: Icons.help_outline,
                    myFunction: () {},
                  ),
                  DrawerItem(
                    title: 'Найзаа урих',
                    icon: Icons.people_outline,
                    myFunction: () {},
                  ),
                  DrawerItem(
                    title: 'Утасны жагсаалт',
                    icon: Icons.contact_mail_outlined,
                    myFunction: () {},
                  ),
                ],
              ),
              // TableCalendar(
              //   headerVisible: true,
              //   headerStyle: HeaderStyle(
              //     formatButtonVisible: false,
              //     titleTextStyle: TextStyle(
              //         fontSize: 18,
              //         color: Color(0xff2675ec),
              //         fontFamily: 'Manrope',
              //         fontWeight: FontWeight.w500),
              //   ),
              //   daysOfWeekHeight: 20,
              //   firstDay: DateTime.utc(2010, 10, 16),
              //   lastDay: DateTime.utc(2030, 3, 14),
              //   focusedDay: DateTime.now(),
              //   calendarStyle: CalendarStyle(
              //       weekendTextStyle: TextStyle(
              //           color: Color(0xff2675ec),
              //           fontFamily: 'Nunito',
              //           fontWeight: FontWeight.w400),
              //       defaultTextStyle: TextStyle(
              //           color: Color(0xff2675ec),
              //           fontFamily: 'Nunito',
              //           fontWeight: FontWeight.w400)),
              // ),
              Divider(),
              SizedBox(
                height: 10,
              ),
              DrawerItem(
                title: 'Log out',
                icon: Icons.logout,
                myFunction: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LogIn()),
                      (Route<dynamic> route) => false);
                },
              )
            ],
          ),
        ),
      ),
    );
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
          // width: double.infinity,
          decoration: BoxDecoration(),
          padding: const EdgeInsets.only(
              left: 10.0, right: 20.0, top: 0.0, bottom: 0.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    child: IconButton(
                        onPressed: () {
                          _globalKey.currentState!.openDrawer();
                        },
                        icon: Icon(
                          Icons.menu,
                          size: 32,
                          color: Colors.black.withOpacity(0.8),
                        )),
                  ),
                  Text(
                    "ChatUp",
                    style: TextStyle(
                        color: Color(0Xff2675EC),
                        fontFamily: 'Nunito',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     search = true;
                  //     _focusNode.requestFocus();
                  //     print('not search');
                  //     setState(() {});
                  //   },
                  //   child: Icon(
                  //     size: 30,
                  //     Icons.search,
                  //     color: Color(0xff7C7C82A6).withOpacity(0.8),
                  //   ),
                  // ),
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
        drawer: DrawerBuilder(myName ?? _dataController.myname),
        body: CustomScrollView(slivers: [
          SliverAppBar(
            elevation: 0,
            floating: true,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
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
                  fillColor: Color.fromARGB(255, 205, 205, 206),
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 5),
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

                              setState(() {});
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
                              size: 25,
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
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 205, 205, 206),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 205, 205,
                          206), // Set the border color when focused
                    ),
                  ),
                  hintText: 'Хайх',
                  hintStyle: const TextStyle(
                    fontFamily: "SF Pro Text",
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff3c3c43),
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
            if (_dataController.roomsLen == 0)
              return SliverToBoxAdapter(
                child: Container(
                    height: MediaQuery.sizeOf(context).height * 2 / 3,
                    decoration: BoxDecoration(border: Border.all()),
                    child: Center(child: Text('no item'))),
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
    String key = chatroomId + myUserName!;

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
    var chatRoomId = getChatRoomIdbyUsername(myUserName!, data["username"]);
    return FutureBuilder(
        future: getthisUserInfo(data["username"], data['Id'], chatRoomId),
        builder: (context, snapshot) {
          return GestureDetector(
            onTap: () async {
              search = false;

              Map<String, dynamic> chatRoomInfoMap = {
                "users": [myUserName, data["username"]],
              };

              print('created channel: $chatRoomId');
              await DatabaseMethods()
                  .createChatRoom(chatRoomId, chatRoomInfoMap);

              if (!_dataController.activeChatroomListeners
                  .contains(chatRoomId)) {
                _dataController.listenForNewMessages(
                    chatRoomId, data["username"], user_native_lans);
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
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
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
        });
  }
}
