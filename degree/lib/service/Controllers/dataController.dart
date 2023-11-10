import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/service/Controllers/listenController.dart';
import 'package:degree/service/data_api.dart';
import 'package:degree/models/chat.dart';
import 'package:degree/service/database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:dio/dio.dart';

class DataController extends GetxController {
  final ListenerController _listenerController = Get.find();
  final dio = Dio();
  String id = '', myName = '', myUserName = '', key = '', email = '';
  Rx<String> picUrl = ''.obs;
  List<String> nativeLans = List.empty(growable: true);
  RxInt unreadChats = 0.obs;
  final firestoreInstance = FirebaseFirestore.instance;
  RxList<Chat> audioMessages = RxList.empty(growable: true);
  RxList<Chat> missedMessages = RxList.empty(growable: true);
  List<String> activeChatroomListeners = [];
  RxInt roomsNum = 0.obs;

  String fcmToken = '';
  Map<String, bool> exitedForEachChannel = {};
  // ignore: non_constant_identifier_names

  Future<void> chatroomsLength() async {
    int len = 0;
    QuerySnapshot querySnapshot =
        await firestoreInstance.collection('chatrooms').get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      String username = doc.id.replaceAll(myUserName, "");
      username = username.replaceAll("_", "");
      len++;
    }
    roomsNum.value = len;
  }

  void fetchCallHistories() async {
    audioMessages = <Chat>[].obs;
    missedMessages = <Chat>[].obs;
    QuerySnapshot querySnapshot =
        await firestoreInstance.collection('chatrooms').get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      //iteration of all chat rooms
      if (doc.id.contains(myUserName)) {
        String username = doc.id.replaceAll(myUserName, "");
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
            if (val['sendBy'] == myUserName) {
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
  }

  void saveUser(String id, String name, String username, String url,
      String searchKey, String email) {
    this.id = id;
    myName = name;
    myUserName = username;
    picUrl.value = url;
    key = searchKey;
    this.email = email;
  }

  void setLastMessage(String chatroomId, Map<String, dynamic> lasMessageMap,
      bool read, String myUserName, String username) {
    Map<String, dynamic> lastMessageInfoMap = {
      "lastMessage": lasMessageMap['lastMessage'],
      "lastMessageSendTs": lasMessageMap['lastMessageSendTs'],
      "time": lasMessageMap['time'],
      "lastMessageSendBy": lasMessageMap['lastMessageSendBy'],
      "read": read,
      "to_msg_$myUserName": 0,
      "to_msg_$username": lasMessageMap['to_msg_$username']
    };

    DatabaseMethods().updateLastMessageSend(chatroomId, lastMessageInfoMap);
  }

  void checkToLastMessage(String chatroomId, String myUserName,
      String ousername, bool read, String sendBy, dynamic lastMessageData) {
//    print('check ${exitedForEachChannel[ousername]}');

    bool exited = exitedForEachChannel[ousername] ?? true;

    if (!read && sendBy == ousername && !exited) {
      setLastMessage(chatroomId, lastMessageData, true, myUserName, ousername);
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
        "sendBy": myUserName,
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
          "lastMessageSendBy": myUserName,
          "read": false,
          "to_msg_$myUserName": 0,
          "to_msg_$ousername": to,
          "sendByNameFrom": myName,
          "sendByNameTo": oname
        };
        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);
      });
      String fcmUser = await fetchthisUserFCM(ousername, chatRoomId);

      Data.sendNotifcation(fcmUser, myUserName, message);
    }
  }

  Future<void> updateUserFCMtoken() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    await usersCollection.doc(id).update({'fcm_$myUserName': fcmToken});
  }

  fetchthisUserFCM(String ousername, String chatroomID) async {
    ousername = chatroomID.replaceAll("_", "").replaceAll(myUserName, "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(ousername.toUpperCase());
    final user = querySnapshot.docs[0].data() as Map<String, dynamic>;
    String fcm = "${user["fcm_$ousername"]}";

    return fcm;
  }

  Future<String> fetchThisUserId(String username) async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    final user = querySnapshot.docs[0].data() as Map<String, dynamic>;
    String fcm = "${user["Id"]}";

    return fcm;
  }

  void sendJoinRequest(String channel) {
    String messageId = randomAlphaNumeric(10);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat.yMd().format(now);
    String hour = DateFormat.Hm().format(now);

    _listenerController.listenToChat(messageId);

    Map<String, dynamic> messageInfoMap = {
      "id": messageId,
      "type": "request",
      "message": "video call invitation",
      "sendBy": myUserName,
      "time": FieldValue.serverTimestamp(),
      "ts": "$hour , $formattedDate",
      "rejected": false,
      "accept": false,
    };

    DatabaseMethods().addMessage(channel, messageId, messageInfoMap);
  }
}
