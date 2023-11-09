import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:degree/models/customer.dart';
import 'package:degree/pages/chat_screens/chatpage.dart';
import 'package:degree/pages/login_screens/login.dart';
import 'package:degree/service/Controllers/listenController.dart';
import 'package:degree/service/data_api.dart';
import 'package:degree/service/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/service/Controllers/dataController.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class HelperChatMainController extends GetxController {
  final DataController _dataController = Get.find();
  final ListenerController _listenerController = Get.find();
  List<String> userNativeLans = [];

  void selectedImage() async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    File img = File(file.path);
    var time = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      await FirebaseStorage.instance
          .ref('${_dataController.myUserName}/$time.png')
          .putFile(img);
    } catch (e) {
      log('image select: $e');
    }

    _dataController.picUrl.value = await FirebaseStorage.instance
        .ref('${_dataController.myUserName}/$time.png')
        .getDownloadURL();

    // await DefaultCacheManager().emptyCache();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_dataController.id)
        .update({"Photo": _dataController.picUrl.value});
  }

  Widget drawerBuilder(String name, BuildContext context) {
    return Drawer(
      width: 300,
      elevation: 30,
      backgroundColor: const Color(0xFfFFFFFF),
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
                      const Text(
                        "Settings",
                        style: TextStyle(
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
                        icon: const Icon(
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
                        width: 90,
                        height: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onLongPress: selectedImage,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30)),
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.5))),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Obx(() {
                                    return CachedNetworkImage(
                                      imageUrl: _dataController.picUrl.value,
                                      width: 100,
                                      height: 100,
                                    );
                                    // return Image.network(
                                    //   _dataController.picUrl.value,
                                    //   fit: BoxFit.cover,
                                    //   height: 100,
                                    //   width: 100,
                                    // );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
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
                    height: 20,
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
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              DrawerItem(
                title: 'Log out',
                icon: Icons.logout,
                myFunction: () async {
                  await FirebaseAuth.instance.signOut();
                  final CollectionReference usersCollection =
                      FirebaseFirestore.instance.collection('users');
                  await usersCollection
                      .doc(_dataController.id)
                      .update({'status': 'offline'});

                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LogIn()),
                      (Route<dynamic> route) => false);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  getthisUserInfo(String username, String usrId, String chatroomId) async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());

    userNativeLans = List<String>.from(querySnapshot.docs[0]["native_lans"]);
    String key = chatroomId + _dataController.myUserName;

    // if (usersBox.get(key) != null)
    // print(
    //     'user  selected lans $usrId: ${usersBox.get(key)!.trans_from_voice}');
    if (usersBox.get(key) == null) {
      //   print('user: $usrId is null');
      usersBox.put(
          chatroomId,
          Customer(
            id: usrId,
            transFromVoice: 'Halh Mongolian',
            transToVoice: userNativeLans[0],
            transFromMsg: 'Halh Mongolian',
            transToMsg: userNativeLans[0],
          ));
    }
  }

  Widget buildResultCard(dynamic data, bool search) {
    var chatRoomId =
        getChatRoomIdbyUsername(_dataController.myUserName, data["username"]);
    return FutureBuilder(
        future: getthisUserInfo(data["username"], data['Id'], chatRoomId),
        builder: (context, snapshot) {
          return GestureDetector(
            onTap: () async {
              search = false;

              Map<String, dynamic> chatRoomInfoMap = {
                "users": [_dataController.myUserName, data["username"]],
              };

              // print('created channel: $chatRoomId');
              await DatabaseMethods()
                  .createChatRoom(chatRoomId, chatRoomInfoMap);

              if (!_dataController.activeChatroomListeners
                  .contains(chatRoomId)) {
                _listenerController.listenForNewMessages(
                    chatRoomId, data["username"], userNativeLans);
              }

              await Get.to(
                  ChatPage(
                    userId: data['Id'],
                    name: data["Name"],
                    profileurl: data["Photo"],
                    username: data["username"],
                    channel: chatRoomId,
                  ),
                  arguments: userNativeLans);
              //  setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
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
                      const SizedBox(
                        width: 20.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["Name"],
                            style: const TextStyle(
                                color: Color(0xff434347),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Nunito',
                                fontSize: 18.0),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            data["username"],
                            style: const TextStyle(
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

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function() myFunction;
  const DrawerItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.myFunction});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: myFunction,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(bottom: 13, left: 10, top: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xff2675ec),
              size: 30,
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                    fontFamily: "Manrope",
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
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
