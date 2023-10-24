import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/DataAPI.dart';
import 'package:degree/service/database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

//late Box<Customer> userBox;

class DataController extends GetxController {
  String id = '',
      myname = '',
      myusername = '',
      picUrl = '',
      key = '',
      email = '';

  List<String> native_lans = List.empty(growable: true);

  // Customer? getUser() {
  //   // return userBox.get('owner');
  //   print(userBox.values);
  //   return userBox.values.toList()[0];
  // }

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

  StreamSubscription<Map<String, dynamic>>? lastMessageStream;
  Map<String, dynamic>? lastMessageData;

  updateChatReadState(String chatId, String channel) async {
    try {
      final chatPairRef = FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(channel)
          .collection('chats')
          .doc(chatId);
      await chatPairRef.update({
        'read': true,
      });
    } catch (e) {
      print('Error updating chat pair: $e');
    }
  }

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
  void startListeningToLastMessage(
      String chatroomId, String myUserName, String ousername) {
    lastMessageStream =
        listenToLastMessage(chatroomId).listen((lastMessageData) {
      print('exitedFromThisChannel ${exitedForEachChannel[ousername]}');
      // Handle updates to the last message data here
      if (lastMessageData['read'] == false &&
          lastMessageData['lastMessageSendBy'] == ousername &&
          exitedForEachChannel[ousername] == false) {
        setLastMessage(
            chatroomId, lastMessageData, true, this.myusername, ousername);
      }
    });
  }

  Stream<Map<String, dynamic>> listenToLastMessage(String chatroomId) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return firestore
        .collection('chatrooms')
        .doc(chatroomId)
        .snapshots()
        .map((chatroomSnapshot) {
      if (chatroomSnapshot.exists) {
        lastMessageData = chatroomSnapshot.data() as Map<String, dynamic>;
        print('listening a last message in Chat Page:$lastMessageData');
        // Return the last message data as a stream
        return lastMessageData ?? {};
      } else {
        print('none here');
        // Return an empty map if the chatroom document doesn't exist
        return {};
      }
    });
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

      int to = 0;

      if (lastMessageData != null &&
          lastMessageData!["lastMessage"] is String) {
        //log('$lastMessageData');
        to = lastMessageData!['to_msg_${ousername}'] + 1;
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
}
