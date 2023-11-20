import 'package:degree/pages/chat_screens/chat_room.dart';
import 'package:degree/service/Controllers/dataController.dart';
import 'package:degree/service/Controllers/listenController.dart';
import 'package:degree/service/Controllers/helpChatMainController.dart';
import 'package:degree/service/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({Key? key}) : super(key: key);

  @override
  State<ChatMainScreen> createState() => _ChatMainScreen();
}

class _ChatMainScreen extends State<ChatMainScreen> {
  final DataController _dataController = Get.find();
  final ListenerController _listenerController = Get.find();
  final HelperChatMainController _helperController = Get.find();
  bool search = false;

  Stream<QuerySnapshot<Object?>>? chatRoomsStream;
  PageController controller = PageController();
  StreamSubscription<Map<String, dynamic>>? lastMessageStream;
  StreamSubscription? chatRoomListSubscription;
  final FocusNode _focusNode = FocusNode();
  TextEditingController textEditingController = TextEditingController();
  RxBool menu = true.obs;
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  var queryResultSet = [];
  var tempSearchStore = [];
  @override
  void initState() {
    ontheload();
    _focusNode.addListener(_handleFocusChange);
    _dataController.chatroomsLength();

    super.initState();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      search = true;
    } else {
      search = false;
    }
    setState(() {});
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
    //print('qset: $queryResultSet');
    var capitalizedValue = value.substring(0, 1).toUpperCase();
    if (queryResultSet.isEmpty && value.length == 1) {
      //print('search in DataStore');
      DatabaseMethods().search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; i++) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      for (var element in queryResultSet) {
        if (element['username'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      }
    }
  }

  getChannels() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  ontheload() async {
    getChannels();
    //print('chat room ${chatRoomsStream}');
    if (chatRoomsStream != null) {
      chatRoomListSubscription =
          chatRoomsStream!.asBroadcastStream().listen((e) {
        _dataController.chatroomsLength();
        var list = e.docs.map((e) {
          return e['to_msg_${_dataController.myUserName}'];
        }).toList();
        if (list.isNotEmpty) {
          _dataController.unreadChats.value =
              list.reduce((value, element) => value + element);
        }
      });
    }

    [Permission.microphone, Permission.camera, Permission.photos].request();
  }

  listenRoom(String channel) async {
    // List<String> userNativeLans = [];
    String username =
        channel.replaceAll("_", "").replaceAll(_dataController.myUserName, "");
    username = username.replaceAll("_", "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());

    String userNativeLan = querySnapshot.docs[0]['myNativeLanguage'];
    //userNativeLans = List<String>.from(querySnapshot.docs[0]["native_lans"]);

    if (!_dataController.activeChatroomListeners.contains(channel)) {
      //  print('update last message with ${channel}');
      _dataController.activeChatroomListeners.add(channel);
      _listenerController.listenForNewMessages(
          channel, username, userNativeLan);
    }
  }

  listenUserData(String username, String channel) async {
    if (!_listenerController.processedUsr.contains(username)) {
      String id = await _dataController.fetchThisUserId(username);
      _listenerController.listenToUserData(id, channel);
      _listenerController.processedUsernames.add(username);
    }
  }

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return const Text('No Data Available');
          } else {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      String username = ds.id
                          .replaceAll("_", "")
                          .replaceAll(_dataController.myUserName, "");
                      _dataController.checkToLastMessage(
                          ds.id,
                          _dataController.myUserName,
                          username,
                          ds["read"],
                          ds["lastMessageSendBy"],
                          ds.data() as Map<String, dynamic>);

                      listenRoom(ds.id);
                      listenUserData(username, ds.id);
                      // _listenerController.listenToUserData(
                      //     _dataController.fetchThisUserId(username));

                      return ChatRoomListTile(
                        chatRoomId: ds.id,
                        lastMessage: ds["lastMessage"],
                        myUsername: _dataController.myUserName,
                        sendBy: ds["lastMessageSendBy"],
                        time: ds["lastMessageSendTs"],
                        read: ds["read"],
                        toMsgNum: ds['to_msg_${_dataController.myUserName}'],
                        name: ds['sendByNameFrom'] == _dataController.myName
                            ? ds['sendByNameTo']
                            : ds['sendByNameFrom'],
                      );
                    }));
          }
        });
  }

  PreferredSizeWidget homeAppbar() {
    return AppBar(
      elevation: 0.5,
      automaticallyImplyLeading: true,
      toolbarHeight: 52,
      backgroundColor: Colors.white,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: Container(),
      flexibleSpace: SafeArea(
        child: Container(
          //   decoration: BoxDecoration(border: Border.all()),
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, top: 18.0, bottom: 0.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    child: GestureDetector(
                      onTap: () {
                        _globalKey.currentState!.openDrawer();
                      },
                      child: Image.asset(
                        'assets/images/img_menu.png',
                        width: 30,
                        height: 20,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: const Text(
                      "ChatUp",
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff2675ec),
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
        appBar: homeAppbar(),
        drawer:
            _helperController.drawerBuilder(_dataController.myName, context),
        onEndDrawerChanged: (isOpened) {},
        body: CustomScrollView(slivers: [
          SliverAppBar(
            elevation: 0,
            floating: true,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: Container(
              height: 40,
              decoration: const BoxDecoration(
                  //border: Border.all()
                  //color: Colors.white,
                  // borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  suffixIcon: IconButton(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    icon: search
                        ? GestureDetector(
                            onTap: () {
                              textEditingController.clear();
                              FocusScope.of(context).requestFocus(FocusNode());

                              search = false;

                              tempSearchStore = [];
                              //print('search');
                              getChannels();

                              //setState(() {});
                            },
                            child: const Icon(
                              size: 25,
                              Icons.close,
                              color: Color(0Xff2675EC),
                            ))
                        : GestureDetector(
                            onTap: () {
                              search = true;
                              _focusNode.requestFocus();
                              // print('not search');
                              setState(() {});
                            },
                            child: const Icon(
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
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 205, 205, 206),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 205, 205,
                          206), // Set the border color when focused
                    ),
                  ),
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    fontFamily: "Manrope",
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff3c3c43).withOpacity(0.5),
                    //height: 22 / 17,
                  ),
                ),
                style: const TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    fontFamily: 'Nunito',
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
          Obx(() {
            if (_dataController.roomsNum.value == 0 && search == false) {
              return SliverToBoxAdapter(
                child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 2 / 3,
                    // decoration: BoxDecoration(border: Border.all()),
                    child: const Center(
                        child: Text(
                      'No item',
                      style: TextStyle(fontFamily: 'Nunito'),
                    ))),
              );
            } else {
              return SliverPadding(
                padding: const EdgeInsets.only(top: 5),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // Build the list of items

                      return search
                          ? ListView(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              primary: false,
                              shrinkWrap: true,
                              children: [...tempSearchStore].map((element) {
                                return _helperController.buildResultCard(
                                    element, search);
                              }).toList())
                          : chatRoomList();
                    },
                    childCount: 1, // Number of items in the list
                  ),
                ),
              );
            }
          }),
        ]));
  }
}
