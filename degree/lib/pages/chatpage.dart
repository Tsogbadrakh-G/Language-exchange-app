import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/DataAPI.dart';
import 'package:degree/Video_call_screen.dart';
import 'package:degree/pages/home.dart';
import 'package:degree/service/Controller.dart';
import 'package:degree/service/model/Customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../service/database.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ChatPage extends StatefulWidget {
  final String name, profileurl, username, channel;
  const ChatPage(
      {required this.name,
      required this.profileurl,
      required this.username,
      required this.channel});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  DataController _dataController = Get.find();
  TextEditingController messagecontroller = new TextEditingController();
  String? myUserName, myProfilePic, myName, myEmail, messageId, chatRoomId;
  Stream? messageStream;
  int translation_status = 1;
  //bool exited = false;

  getthesharedpref() async {
    // print('user: $user');
    myUserName = _dataController.myusername;
    myName = _dataController.myname;
    myProfilePic = _dataController.picUrl;
    myEmail = _dataController.email;

    print(
        'name $myName, usrname: $myUserName, pic: $myProfilePic, id: $myEmail, exited:${_dataController.exitedForEachChannel[myUserName]} ');
    chatRoomId = widget.channel;
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    await getAndSetMessages();
    _dataController
        .exitedForEachChannel[myUserName ?? _dataController.myusername] = false;

    print('listening in chatpage name: ${widget.channel}');
    _dataController.startListeningToLastMessage(
        widget.channel, myUserName!, widget.username);

    setState(() {});
  }

//

  @override
  void initState() {
    super.initState();
    ontheload();

    print('object');
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight:
                      sendByMe ? Radius.circular(0) : Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft:
                      sendByMe ? Radius.circular(24) : Radius.circular(0)),
              color: sendByMe
                  ? Color.fromARGB(255, 234, 236, 240)
                  : Color.fromARGB(255, 211, 228, 243)),
          child: Text(
            message,
            style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.w500),
          ),
        )),
      ],
    );
  }

  Widget chatMessage() {
    return StreamBuilder(
        stream: messageStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 90.0, top: 130),
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];

                    return chatMessageTile(
                        ds["message"], myUserName == ds["sendBy"]);
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  List<String> voice_in_lans = [
    'Bengali',
    'Catalan',
    'Czech',
    'Danish',
    'Dutch',
    'English',
    'Estonian',
    'Finnish',
    'French',
    'German',
    'Hindi',
    'Indonesian',
    'Italian',
    'Japanese',
    'Korean',
    'Maltese',
    'Mandarin Chinese',
    'Modern Standard Arabic',
    'Northern Uzbek',
    'Polish',
    'Portuguese',
    'Romanian',
    'Russian',
    'Slovak',
    'Spanish',
    'Swahili',
    'Swedish',
    'Tagalog',
    'Telugu',
    'Thai',
    'Turkish',
    'Ukrainian',
    'Urdu',
    'Vietnamese',
    'Welsh',
    'Western Persian'
  ];

  final List<String> chat_in_lans = [
    'Halh Mongolian',
    'Bengali',
    'Catalan',
    'Czech',
    'Danish',
    'Dutch',
    'English',
    'Estonian',
    'Finnish',
    'French',
    'German',
    'Hindi',
    'Indonesian',
    'Italian',
    'Japanese',
    'Korean',
    'Maltese',
    'Mandarin Chinese',
    'Modern Standard Arabic',
    'Northern Uzbek',
    'Polish',
    'Portuguese',
    'Romanian',
    'Russian',
    'Slovak',
    'Spanish',
    'Swahili',
    'Swedish',
    'Tagalog',
    'Telugu',
    'Thai',
    'Turkish',
    'Ukrainian',
    'Urdu',
    'Vietnamese',
    'Welsh',
    'Western Persian'
  ];
  List<String> voice_out_lans = [
    'Bengali',
    'Catalan',
    'Czech',
    'Danish',
    'Dutch',
    'English',
    'Estonian',
    'Finnish',
    'French',
    'German',
    'Hindi',
    'Indonesian',
    'Italian',
    'Japanese',
    'Korean',
    'Maltese',
    'Mandarin Chinese',
    'Modern Standard Arabic',
    'Northern Uzbek',
    'Polish',
    'Portuguese',
    'Romanian',
    'Russian',
    'Slovak',
    'Spanish',
    'Swahili',
    'Swedish',
    'Tagalog',
    'Telugu',
    'Thai',
    'Turkish',
    'Ukrainian',
    'Urdu',
    'Vietnamese',
    'Welsh',
    'Western Persian'
  ];

  final List<String> chat_out_lans = [
    'Halh Mongolian',
    'Bengali',
    'Catalan',
    'Czech',
    'Danish',
    'Dutch',
    'English',
    'Estonian',
    'Finnish',
    'French',
    'German',
    'Hindi',
    'Indonesian',
    'Italian',
    'Japanese',
    'Korean',
    'Maltese',
    'Mandarin Chinese',
    'Modern Standard Arabic',
    'Northern Uzbek',
    'Polish',
    'Portuguese',
    'Romanian',
    'Russian',
    'Slovak',
    'Spanish',
    'Swahili',
    'Swedish',
    'Tagalog',
    'Telugu',
    'Thai',
    'Turkish',
    'Ukrainian',
    'Urdu',
    'Vietnamese',
    'Welsh',
    'Western Persian'
  ];

  String? selectedValueFrom;
  String? selectedValueTo;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Color(0xFF553370),
      body: Container(
        child: Stack(
          children: [
            Container(
                // margin: EdgeInsets.only(top: 50.0),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: chatMessage()),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              alignment: Alignment.bottomCenter,
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: TextField(
                    controller: messagecontroller,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message",
                        hintStyle: TextStyle(color: Colors.black45),
                        suffixIcon: GestureDetector(
                            onTap: () {
                              _dataController.addMessage(
                                  widget.channel,
                                  messagecontroller.text,
                                  selectedValueFrom ?? "Halh Mongolian",
                                  selectedValueTo ?? "Halh Mongolian",
                                  widget.username,
                                  widget.name);

                              messagecontroller.clear();
                            },
                            child: Icon(Icons.send_rounded))),
                  ),
                ),
              ),
            ),
            Container(
              height: 100,
              width: double.infinity,
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 233, 232, 229)),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Translate from'),
                          SizedBox(height: 5),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      selectedValueFrom ?? 'Halh Mongolian',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              items: translation_status % 2 == 0
                                  ? voice_in_lans
                                      .map((String item) =>
                                          DropdownMenuItem<String>(
                                              value: item,
                                              child: Container(
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )))
                                      .toList()
                                  : chat_in_lans
                                      .map((String item) =>
                                          DropdownMenuItem<String>(
                                              value: item,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    item,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              )))
                                      .toList(),
                              value: selectedValueFrom,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedValueFrom = value;
                                });
                                print('vl: ${selectedValueFrom}');
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: 140,
                                padding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.black26,
                                    ),
                                    //color: Color(0xffC6E2EE),
                                    color: Colors.white),
                                elevation: 2,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                ),
                                offset: const Offset(-20, 0),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(40),
                                  thickness:
                                      MaterialStateProperty.all<double>(6),
                                  thumbVisibility:
                                      MaterialStateProperty.all<bool>(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          IconButton(
                            onPressed: () {
                              translation_status++;
                              selectedValueFrom = null;
                              selectedValueTo = null;
                              setState(() {});
                            },
                            icon: translation_status % 2 == 0
                                ? Icon(
                                    Icons.keyboard_voice_outlined,
                                    size: 35,
                                  )
                                : Icon(
                                    Icons.chat_bubble_outline,
                                    size: 30,
                                  ),
                          )
                        ],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Translate to'),
                          SizedBox(height: 5),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      selectedValueTo ?? 'Halh Mongolian',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              items: translation_status % 2 == 0
                                  ? voice_out_lans
                                      .map((String item) =>
                                          DropdownMenuItem<String>(
                                              value: item,
                                              child: Container(
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )))
                                      .toList()
                                  : chat_out_lans
                                      .map((String item) =>
                                          DropdownMenuItem<String>(
                                              value: item,
                                              child: Container(
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )))
                                      .toList(),
                              value: selectedValueTo,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedValueTo = value;
                                });
                                print('vl: ${selectedValueTo}');
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: 140,
                                padding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.black26,
                                    ),
                                    //color: Color(0xffC6E2EE),
                                    color: Colors.white),
                                elevation: 2,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                ),
                                offset: const Offset(-20, 0),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(40),
                                  thickness:
                                      MaterialStateProperty.all<double>(6),
                                  thumbVisibility:
                                      MaterialStateProperty.all<bool>(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      elevation: 0.5,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 70,
              child: Row(
                //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      _dataController.exitedForEachChannel[
                          myUserName ?? _dataController.myusername] = true;
                      Get.to(Home());
                    },
                    icon: Image.asset('assets/images/ic_chevron_left.png',
                        height: 20, width: 20, color: Colors.black),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      // border: Border.all(color: (user?.online ?? false) ? LimeColors.primaryColor : const Color(0xffd8d8d8), width: size > 40 ? 3 : 1.5),
                    ),
                    width: 50,
                    height: 50,
                    child: myProfilePic != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            imageUrl: myProfilePic!,
                            // placeholder: (context, url) => _textAvatar(text: LimeChatHelper.getChannelName(channel!)),
                            // errorWidget: (context, url, e) => _textAvatar(
                            //   text: LimeChatHelper.getChannelName(channel!),
                            // ),
                          ))
                        : Offstage(),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    direction: Axis.vertical,
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Text(
                        widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.username,
                        //  LimeChatHelper.getChannelUserNumber(channel),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Spacer(),
                  Visibility(
                    visible: true,
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 24,
                      child: RawMaterialButton(
                        onPressed: () async {
                          if (translation_status % 2 == 0) {
                            int intValue = Random().nextInt(10000);
                            String token = await Data.generate_token(
                                widget.channel, intValue);

                            print('channel token $token, uid: $intValue');
                            Get.to(Video_call_screen(
                                widget.channel,
                                myUserName!,
                                widget.username,
                                selectedValueFrom ?? 'Halh Mongolian',
                                selectedValueTo ?? 'Halh Mongolian',
                                token,
                                intValue));
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Ta voice translation icon-ийг сонгоно уу.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor:
                                  Color.fromARGB(255, 199, 197, 197),
                              textColor: Colors.black,
                            );
                          }
                        },
                        shape: const CircleBorder(),
                        child: Image.asset("assets/images/ic_chat_video.png",
                            color: Get.theme.colorScheme.secondary,
                            width: 20,
                            height: 20),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: 20,
                  // ),
                  Visibility(
                    visible: true,
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 24,
                      child: RawMaterialButton(
                        onPressed: () async {},
                        shape: const CircleBorder(),
                        child: Image.asset("assets/images/ic_chat_more.png",
                            color: Get.theme.colorScheme.secondary,
                            width: 20,
                            height: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('closing chatpage');
    _dataController
        .exitedForEachChannel[myUserName ?? _dataController.myusername] = true;
    // lastMessageStream?.cancel();
    super.dispose();
  }
}
