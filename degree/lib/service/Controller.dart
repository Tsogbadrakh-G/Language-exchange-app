import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/service/data_api.dart';
import 'package:degree/pages/Video_call_screen.dart';
import 'package:degree/service/custom_source.dart';
import 'package:degree/models/chat.dart';
import 'package:degree/service/database.dart';
import 'package:degree/models/customer.dart';
import 'package:degree/service/somni_alert.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:random_string/random_string.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
//late Box<Customer> userBox;

class DataController extends GetxController {
  final dio = Dio();
  String id = '', myname = '', myusername = '', key = '', email = '';
  Rx<String> picUrl = ''.obs;
  List<String> nativeLans = List.empty(growable: true);
  RxInt unreadChats = 0.obs;
  final firestoreInstance = FirebaseFirestore.instance;
  RxList<Chat> audioMessages = RxList.empty(growable: true);
  RxList<Chat> missedMessages = RxList.empty(growable: true);
  List<String> activeChatroomListeners = [];
  RxInt roomsLen = 0.obs;

  String fcmToken = '';
  Map<String, bool> exitedForEachChannel = {};
  // ignore: non_constant_identifier_names
  Map<String, bool> exitedForEachChannel_Voice = {};

  Future<void> updateUserFCMtoken() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    await usersCollection.doc(id).update({'fcm_$myusername': fcmToken});
  }

  Future<void> chatroomsLength() async {
    int len = 0;
    QuerySnapshot querySnapshot =
        await firestoreInstance.collection('chatrooms').get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      String username = doc.id.replaceAll(myusername, "");
      username = username.replaceAll("_", "");
      len++;
    }
    roomsLen.value = len;
  }

  void getCallHistories() async {
    audioMessages = <Chat>[].obs;
    missedMessages = <Chat>[].obs;
    QuerySnapshot querySnapshot =
        await firestoreInstance.collection('chatrooms').get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      //iteration of all chat rooms
      if (doc.id.contains(myusername)) {
        String username = doc.id.replaceAll(myusername, "");
        username = username.replaceAll("_", "");

        QuerySnapshot chatSnapshot = await firestoreInstance
            .collection('chatrooms')
            .doc(doc.id)
            .collection('chats')
            .get();

        for (var chatDoc in chatSnapshot.docs) {
          Map<String, dynamic> val = chatDoc.data() as Map<String, dynamic>;
          Chat ret;

          if (val['type'] == 'request') {
            String callStatus = '';
            if (val['sendBy'] == myusername) {
              callStatus = 'outbound';
            } else if (val['rejected'] as bool == true)
              // ignore: curly_braces_in_flow_control_structures
              callStatus = 'missed';
            else if (val['accept'] as bool == true)
              // ignore: curly_braces_in_flow_control_structures
              callStatus = 'inbound';
            else
              // ignore: curly_braces_in_flow_control_structures
              callStatus = 'missed';

            List<String> parts = val['ts'].toString().split(',');

            List<String> times = parts[0].split(':');
            int hour = int.parse(times[0]);
            int min = int.parse(times[1]);

            List<String> dates = parts[1].split('/');

            //  print('date: ${dates[1]}');
            int year = int.parse(dates[2]);
            int month = int.parse(dates[0]);
            int day = int.parse(dates[1]);

            ret = Chat(
                id: val['id'].toString(),
                message: val['message'].toString(),
                chatuserName: username,
                callStatus: callStatus,
                time: val['ts'].toString(),
                channel: doc.id,
                officialTime: DateTime(year, month, day, hour, min));
            audioMessages.add(ret);
            if (callStatus == 'missed') missedMessages.add(ret);
          }
        }
      }
    }
    audioMessages.sort((a, b) => b.officialTime.compareTo(a.officialTime));
    missedMessages.sort((a, b) => b.officialTime.compareTo(a.officialTime));
    // print('audio chats len : ${audioMessages.length}');
    // print('missed audio chats len : ${missedMessages.length}');
  }

  void saveUser(String id, String name, String username, String url,
      String searchKey, String email) {
    this.id = id;
    myname = name;
    myusername = username;
    picUrl.value = url;
    key = searchKey;
    this.email = email;
  }

  //Map<String, dynamic>? lastMessageData;

  // updateChatReadState(String chatId, String channel) async {
  //   try {
  //     final chatPairRef = FirebaseFirestore.instance
  //         .collection('chatrooms')
  //         .doc(channel)
  //         .collection('chats')
  //         .doc(chatId);
  //     await chatPairRef.update({
  //       'read': true,
  //     });
  //   } catch (e) {
  //     print('Error updating chat pair: $e');
  //   }
  // }

  void setLastMessage(String chatroomId, Map<String, dynamic> lasMessageMap,
      bool read, String myUserName, String username) {
    Map<String, dynamic> lastMessageInfoMap = {
      "lastMessage": lasMessageMap['lastMessage'],
      "lastMessageSendTs": lasMessageMap['lastMessageSendTs'],
      "time": lasMessageMap['time'],
      "lastMessageSendBy": lasMessageMap['lastMessageSendBy'],
      "read": read,
      "to_msg_$myusername": 0,
      "to_msg_$username": lasMessageMap['to_msg_$username']
    };

    DatabaseMethods().updateLastMessageSend(chatroomId, lastMessageInfoMap);
  }

  void checkToLastMessage(String chatroomId, String myUserName,
      String ousername, bool read, String sendBy, dynamic lastMessageData) {
//    print('check ${exitedForEachChannel[ousername]}');

    bool exited = exitedForEachChannel[ousername] ?? true;

    if (!read && sendBy == ousername && !exited) {
      setLastMessage(chatroomId, lastMessageData, true, myusername, ousername);
    }
  }

  addMessage(String chatRoomId, String text, String from, String transto,
      String ousername, String oname) async {
    if (text != "") {
      String message = text;
      text = "";
      if (from != transto) {
        String translationText = await Data.sendText(message, from, transto);
        message = "$message\n$translationText";
      }
      String messageId = randomAlphaNumeric(10);

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);

      Map<String, dynamic> messageInfoMap = {
        "id": messageId,
        "type": "text",
        "message": message,
        "sendBy": myusername,
        "ts": now,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": picUrl.value,
        //"missed": false
      };

      DocumentSnapshot ds = await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .get();
      Map<String, dynamic>? lastMessageData = ds.data() as Map<String, dynamic>;

      int to = 0;

      if (lastMessageData["lastMessage"] is String) {
        to = lastMessageData['to_msg_$ousername'] + 1;
      } else {
        to = 1;
      }

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": myusername,
          "read": false,
          "to_msg_$myusername": 0,
          "to_msg_$ousername": to,
          "sendByNameFrom": myname,
          "sendByNameTo": oname
        };
        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);
      });
      String fcmUser = await getthisUserFCM(ousername, chatRoomId);

      Data.sendNotifcation(fcmUser, myusername, message);
    }
  }

  getthisUserFCM(String ousername, String chatroomID) async {
    ousername = chatroomID.replaceAll("_", "").replaceAll(myusername, "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(ousername.toUpperCase());
    final user = querySnapshot.docs[0].data() as Map<String, dynamic>;
    String fcm = "${user["fcm_$ousername"]}";

    return fcm;
  }

  Map<String, StreamSubscription> newMessages = {};

  final Set<String> processedMessageIds = Set<String>();
  void listenForNewMessages(String channel, String username,
      List<String> userNativeLans, BuildContext context) {
    final CollectionReference messagesCollection =
        FirebaseFirestore.instance.collection('chatrooms/$channel/chats');

    newMessages[channel] =
        messagesCollection.snapshots().listen((QuerySnapshot snapshot) {
      // ignore: avoid_function_literals_in_foreach_calls
      snapshot.docChanges.forEach((change) async {
        final messageData = change.doc.data() as Map<String, dynamic>;

        if (!processedMessageIds.contains(messageData['id'])) {
          bool exited = exitedForEachChannel_Voice[username] ?? true;
          print(
              'new message: $messageData, widget username: $username, exited: $exited');
          QuerySnapshot querySnapshot =
              await DatabaseMethods().getUserInfo(username.toUpperCase());
          final user = querySnapshot.docs[0].data() as Map<String, dynamic>;
          String status = user['status'];

          if (messageData["type"] == 'request' &&
              messageData["sendBy"] == username &&
              messageData["rejected"] as bool == false &&
              messageData["accept"] as bool == false) {
            if (status == 'offline') {
              final chatPairRef = FirebaseFirestore.instance
                  .collection('chatrooms')
                  .doc(channel)
                  .collection('chats')
                  .doc(messageData["id"]);
              await chatPairRef.update({
                'rejected': true,
              });
            } else if (exited) {
              await SomniAlerts.alertVideoCall(
                messageData["sendBy"],
                () async {
                  int intValue = Random().nextInt(10000);
                  String token = await Data.generateToken(channel, intValue);
                  String key = channel + myusername;
                  Customer? user = usersBox.get(key);
                  String from = '', to = '';
                  if (user != null) {
                    from = user.transFromVoice;
                    to = user.transToVoice;
                  } else {
                    usersBox.put(
                        channel,
                        Customer(
                          id: '1',
                          transFromVoice: 'Halh Mongolian',
                          transToVoice: userNativeLans[0],
                          transFromMsg: 'Halh Mongolian',
                          transToMsg: userNativeLans[0],
                        ));
                    from = 'Halh Mongolian';
                    to = userNativeLans[0];
                  }
                  Get.back();
                  Get.to(VideoCallScreen(channel, myusername, username, from,
                      to, token, intValue));
                  try {
                    final chatPairRef = FirebaseFirestore.instance
                        .collection('chatrooms')
                        .doc(channel)
                        .collection('chats')
                        .doc(messageData["id"]);
                    await chatPairRef.update({
                      'accept': true,
                    });
                  } catch (e) {
                    ('Error updating chat pair: $e');
                  }
                },
                () async {
                  try {
                    final chatPairRef = FirebaseFirestore.instance
                        .collection('chatrooms')
                        .doc(channel)
                        .collection('chats')
                        .doc(messageData["id"]);
                    await chatPairRef.update({
                      'rejected': true,
                    });
                  } catch (e) {
                    print('Error updating chat pair: $e');
                  }
                  Get.back();
                },
              );
            }
          } else if (messageData["type"] == "audio" && exited) {
            updateChatReadState(messageData["id"], false, true, channel);
          } else if (messageData["type"] == "audio" &&
              messageData["sendBy"] == username &&
              messageData["missed"] == false &&
              messageData["read"] == false) {
            downloadAndPlayAudio(
                messageData["url"], messageData["id"], channel);
          }
          processedMessageIds.add(messageData['id']);
        }
      });
    });
  }

  downloadAndPlayAudio(String url, String chatId, String channel) async {
    final res =
        await dio.get(url, options: Options(responseType: ResponseType.bytes));
    print('download: ${res.data}');

    final audioPlayer = AudioPlayer();

    await audioPlayer.setAudioSource(CustomSource(res.data));

    await audioPlayer.load();

    await audioPlayer.play();

    updateChatReadState(chatId, true, false, channel);
  }

  updateChatReadState(
      String chatId, bool read, bool missed, String channel) async {
    //print('update data: id-$chatId, read- $read, miss- $missed');
    try {
      final chatPairRef = FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(channel)
          .collection('chats')
          .doc(chatId);
      await chatPairRef.update({
        'read': read,
        'missed': missed,
      });
    } catch (e) {
      print('Error updating chat pair: $e');
    }
  }

  void sendJoinRequest(String channel) {
    String messageId = randomAlphaNumeric(10);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat.yMd().format(now);
    String hour = DateFormat.Hm().format(now);

    Map<String, dynamic> messageInfoMap = {
      "id": messageId,
      "type": "request",
      "message": "video call invitation",
      "sendBy": myusername,
      "time": FieldValue.serverTimestamp(),
      "ts": hour + " , " + formattedDate,
      "rejected": false,
      "accept": false,
    };

    DatabaseMethods().addMessage(channel, messageId, messageInfoMap);
  }
}
