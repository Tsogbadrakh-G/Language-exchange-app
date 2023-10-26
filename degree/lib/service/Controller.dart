import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/DataAPI.dart';
import 'package:degree/Video_call_screen.dart';
import 'package:degree/custom_source.dart';
import 'package:degree/models/Chat.dart';
import 'package:degree/service/database.dart';
import 'package:degree/service/model/Customer.dart';
import 'package:degree/service/model/somni_alert.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:random_string/random_string.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
//late Box<Customer> userBox;

class DataController extends GetxController {
  final dio = Dio();
  String id = '',
      myname = '',
      myusername = '',
      picUrl = '',
      key = '',
      email = '';

  List<String> native_lans = List.empty(growable: true);
  RxInt unreadChats = 0.obs;
  // Customer? getUser() {
  //   // return userBox.get('owner');
  //   print(userBox.values);
  //   return userBox.values.toList()[0];
  // }
  final firestoreInstance = FirebaseFirestore.instance;
  RxList<Chat> audioMessages = RxList.empty(growable: true);
  RxList<Chat> missedMessages = RxList.empty(growable: true);

  void getChatRoomIds() async {
    QuerySnapshot querySnapshot =
        await firestoreInstance.collection('chatrooms').get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      String username = doc.id.replaceAll(myusername, "");
      username = username.replaceAll("_", "");
      // log('user name: $username');
      QuerySnapshot chatSnapshot = await firestoreInstance
          .collection('chatrooms')
          .doc(doc.id)
          .collection('chats')
          .get();

      chatSnapshot.docs.forEach((chatDoc) {
        Map<String, dynamic> val = chatDoc.data() as Map<String, dynamic>;

        Chat ret;

        if (val['type'] == 'request') {
          String callStatus = '';
          if (val['sendBy'] == myusername)
            callStatus = 'outbound';
          else if (val['rejected'] as bool == true)
            callStatus = 'missed';
          else if (val['accept'] as bool == true)
            callStatus = 'inbound';
          else
            callStatus = 'missed';

          int year = int.parse(val['ts'].toString().substring(14, 18));
          int month = int.parse(val['ts'].toString().substring(8, 10));
          int day = int.parse(val['ts'].toString().substring(11, 13));
          int hour = int.parse(val['ts'].toString().substring(0, 2));
          int min = int.parse(val['ts'].toString().substring(3, 5));
          ret = Chat(
              id: val['id'].toString(),
              message: val['message'].toString(),
              chatuserName: val['sendBy'].toString(),
              callStatus: callStatus,
              time: val['ts'].toString(),
              channel: doc.id,
              officialTime: DateTime(year, month, day, hour, min));
          audioMessages.add(ret);
          if (callStatus == 'missed') missedMessages.add(ret);
        }

        audioMessages.sort((a, b) => b.officialTime.compareTo(a.officialTime));
        missedMessages.sort((a, b) => b.officialTime.compareTo(a.officialTime));
      });

      print('audio chats len : ${audioMessages.length}');
    }
  }

  Map<String, bool> exitedForEachChannel = Map();
  Map<String, bool> exitedForEachChannel_Voice = Map();

  void SaveUser(String id, String name, String username, String picUrl,
      String searchKey, String email) {
    this.id = id;
    this.myname = name;
    this.myusername = username;
    this.picUrl = picUrl;
    this.key = searchKey;
    this.email = email;

    // userBox.put(
    //     'owner',
    //     Customer(
    //         id: id,
    //         name: name,
    //         username: username,
    //         picUrl: picUrl,
    //         SearchKey: searchKey,
    //         email: email));
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
  // Stream<Map<String, dynamic>> listenToLastMessage(String chatroomId) {
  //   FirebaseFirestore firestore = FirebaseFirestore.instance;

  //   return firestore
  //       .collection('chatrooms')
  //       .doc(chatroomId)
  //       .snapshots()
  //       .map((chatroomSnapshot) {
  //     if (chatroomSnapshot.exists) {
  //       lastMessageData = chatroomSnapshot.data() as Map<String, dynamic>;
  //       print('listening a last message in Chat Page:$lastMessageData');
  //       // Return the last message data as a stream
  //       return lastMessageData ?? {};
  //     } else {
  //       print('none here');
  //       // Return an empty map if the chatroom document doesn't exist
  //       return {};
  //     }
  //   });
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
      "to_msg_${username}": lasMessageMap['to_msg_${username}']
    };

    print('set last message');
    DatabaseMethods().updateLastMessageSend(chatroomId, lastMessageInfoMap);
  }

//Listening last chat
  void CheckToLastMessage(String chatroomId, String myUserName,
      String ousername, bool read, String sendBy, dynamic lastMessageData) {
    print('check ${exitedForEachChannel[ousername]}');

    bool exited = exitedForEachChannel[ousername] ?? true;
    // print('exited $exited, username: $ousername, sendBy: $sendBy');
    if (!read && sendBy == ousername && !exited) {
      setLastMessage(
          chatroomId, lastMessageData, true, this.myusername, ousername);
    }
    // });
  }

  addMessage(String chatRoomId, String text, String from, String transto,
      String ousername, String oname) async {
    if (text != "") {
      String message = text;
      text = "";
      if (from != transto) {
        String translation_text = await Data.sendText(message, from, transto);
        message = message + "\n${translation_text}";
      }
      String messageId = randomAlphaNumeric(10);

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);

      Map<String, dynamic> messageInfoMap = {
        "id": messageId,
        "type": "text",
        "message": message,
        "sendBy": this.myusername,
        "ts": now,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": this.picUrl,
        //"missed": false
      };
      print('room $chatRoomId');

      DocumentSnapshot ds = await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .get();
      Map<String, dynamic>? lastMessageData = ds.data() as Map<String, dynamic>;

      print('lastmessage dta: $lastMessageData');
      int to = 0;

      if (lastMessageData != null && lastMessageData["lastMessage"] is String) {
        //log('$lastMessageData');
        to = lastMessageData['to_msg_${ousername}'] + 1;
      } else
        to = 1;

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": this.myusername,
          "read": false,
          "to_msg_${this.myusername}": 0,
          "to_msg_${ousername}": to,
          "sendByNameFrom": myname,
          "sendByNameTo": oname
        };
        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);
      });
    }
  }

  // final firestoreInstance = FirebaseFirestore.instance;
  // void getChatRoomIds() async {
  //   QuerySnapshot querySnapshot =
  //       await firestoreInstance.collection('chatrooms').get();
  //   for (QueryDocumentSnapshot doc in querySnapshot.docs) {
  //     String username = doc.id.replaceAll(myusername, "");
  //     username = username.replaceAll("_", "");
  //     //  log('user name: $username');
  //     QuerySnapshot chatSnapshot = await firestoreInstance
  //         .collection('chatrooms')
  //         .doc(doc.id)
  //         .collection('chats')
  //         .get();

  //     chatSnapshot.docs.forEach((chatDoc) {
  //       Map<String, dynamic> val = chatDoc.data() as Map<String, dynamic>;

  //       Chat ret;

  //       if (val['type'] == 'request') {
  //         String callStatus = '';
  //         if (val['sendBy'] == myusername)
  //           callStatus = 'outbound';
  //         else if (val['rejected'] as bool == true)
  //           callStatus = 'missed';
  //         else if (val['accept'] as bool == true)
  //           callStatus = 'inbound';
  //         else
  //           callStatus = 'missed';

  //         int year = int.parse(val['ts'].toString().substring(14, 18));
  //         int month = int.parse(val['ts'].toString().substring(8, 10));
  //         int day = int.parse(val['ts'].toString().substring(11, 13));
  //         int hour = int.parse(val['ts'].toString().substring(0, 2));
  //         int min = int.parse(val['ts'].toString().substring(3, 5));
  //         ret = Chat(
  //             id: val['id'].toString(),
  //             message: val['message'].toString(),
  //             chatuserName: val['sendBy'].toString(),
  //             callStatus: callStatus,
  //             time: val['ts'].toString(),
  //             channel: doc.id,
  //             officialTime: DateTime(year, month, day, hour, min));
  //         audioMessages.add(ret);
  //       }
  //       audioMessages.sort((a, b) => b.officialTime.compareTo(a.officialTime));
  //     });

  //     // print('chats $chatMessages in chatroom with ${doc.id}');
  //     print('audio chats len : ${audioMessages.length}');
  //   }

  //   //setState(() {}); // Notify Flutter to rebuild the UI with the chat room IDs.
  // }

  final Set<String> processedMessageIds = Set<String>();
  void listenForNewMessages(
      String channel, String username, List<String> user_native_lans) {
    final CollectionReference messagesCollection =
        FirebaseFirestore.instance.collection('chatrooms/${channel}/chats');

    messagesCollection.snapshots().listen((QuerySnapshot snapshot) {
      snapshot.docChanges.forEach((change) async {
        final messageData = change.doc.data() as Map<String, dynamic>;

        if (!processedMessageIds.contains(messageData['id'])) {
          // This message is newly added
          // getChatRoomIds();
          bool exited = exitedForEachChannel_Voice[username] ?? true;
          print(
              'new message: ${messageData}, widget username: ${username}, exited: ${exited}');

          // if (messageData["type"] == 'request') {
          //   String callStatus = '';
          //   if (messageData['sendBy'] == myusername)
          //     callStatus = 'outbound';
          //   else if (messageData['rejected'] as bool == true)
          //     callStatus = 'missed';
          //   else if (messageData['accept'] as bool == true)
          //     callStatus = 'inbound';
          //   else
          //     callStatus = 'missed';
          //   int year =
          //       int.parse(messageData['ts'].toString().substring(14, 18));
          //   int month =
          //       int.parse(messageData['ts'].toString().substring(8, 10));
          //   int day = int.parse(messageData['ts'].toString().substring(11, 13));
          //   int hour = int.parse(messageData['ts'].toString().substring(0, 2));
          //   int min = int.parse(messageData['ts'].toString().substring(3, 5));
          //   Chat ret = Chat(
          //       id: messageData['id'].toString(),
          //       message: messageData['message'].toString(),
          //       chatuserName: messageData['sendBy'].toString(),
          //       callStatus: callStatus,
          //       time: messageData['ts'].toString(),
          //       channel: 'GTSOG321_TEST1',
          //       officialTime: DateTime(year, month, day, hour, min));
          //   audioMessages.add(ret);
          //   print('call history added');
          // }
          if (messageData["type"] == 'request') {
            audioMessages.clear();
            missedMessages.clear();
            getChatRoomIds();
          }

          if (messageData["type"] == 'request' &&
              messageData["sendBy"] != myusername &&
              messageData["rejected"] as bool == false &&
              messageData["accept"] as bool == false &&
              exited) {
            await SomniAlerts.alertBoxVertical(
              onClose: () async {
                Get.back();
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
              },
              titleWidget: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w500),
                ),
              ),
              textWidget: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RichText(
                    textScaleFactor:
                        MediaQuery.of(Get.context!).textScaleFactor,
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Видео дуудлага',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w400),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Танд',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '$username хэрэглэгчээс'),
                        // TextSpan(
                        //     text: 'stat ',
                        //     style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'видео дуудлага ирж байна.'),
                      ],
                    )),
              ),
              button1: () async {
                int intValue = Random().nextInt(10000);
                String token = await Data.generate_token(channel, intValue);
                String key = channel + myusername;
                Customer? user = usersBox.get(key);
                String from = '', to = '';
                if (user != null) {
                  from = user.trans_from_voice;
                  to = user.trans_to_voice;
                } else {
                  usersBox.put(
                      channel,
                      Customer(
                        id: '1',
                        trans_from_voice: 'Halh Mongolian',
                        trans_to_voice: user_native_lans[0],
                        trans_from_msg: 'Halh Mongolian',
                        trans_to_msg: user_native_lans[0],
                      ));
                  from = 'Halh Mongolian';
                  to = user_native_lans[0];
                }
                Get.to(Video_call_screen(
                    channel, myusername, username, from, to, token, intValue));
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
                  print('Error updating chat pair: $e');
                }
              },
              button2: () async {
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
              imgAsset: 'alert/alert_reminder',
              button1Text: 'Дуудлага авах 🤙',
              button2Text: 'Дуулага салгах 😴',
            );
          }
          if (messageData["type"] == "audio" && exited) {
            updateChatReadState(messageData["id"], false, true, channel);
          } else if (messageData["type"] == "audio" &&
              messageData["sendBy"] == username &&
              messageData["missed"] == false &&
              messageData["read"] == false) {
            downloadAndPlayAudio(
                messageData["url"], messageData["id"], channel);
          }
          processedMessageIds.add(messageData['id']);
          // Process and display the new message as needed
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
    print('update data: id-$chatId, read- $read, miss- $missed');
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
