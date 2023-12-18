import 'dart:developer';
import 'package:degree/models/customer.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';

late Box<Customer> usersBox;

class Data {
  List<String> inputLanguages = [];

  List<String> outputLanguages = [];

  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static const url = 'http://13.125.68.71:5000/todo';
  //static final url = 'http://192.168.1.98:5000/todo';

  static Future<dynamic> sendAudio(String path, String from, String to,
      String tranlsation, String chatroomId, String myUsername) async {
    final dio = Dio();

    FormData formData = FormData.fromMap({
      'type': "audio",
      'audio': await MultipartFile.fromFile(path, filename: 'record.wav'),
      'input': from,
      'output': to,
      'translation': tranlsation,
      'roomId': chatroomId,
      'myUsername': myUsername
    });

    print('pre req');
    final response = await dio.post(
      url,
      data: formData,
      options: Options(headers: {"Content-Type": "multipart/form-data"}),
    );
    print('response: ${response}');

    if (response.statusCode == 200) {
      //translated audio file URL on the server
      return response.data['message'];
    } else {
      log('unsuccessfull req');
      return 'error';
    }
  }

  static Future<String> sendText(String text, String from, String to) async {
    final dio = Dio();

    FormData formData = FormData.fromMap({
      'type': "text",
      'text': text,
      'input': from,
      'output': to,
    });

    final response = await dio.post(
      url,
      data: formData,
      options: Options(headers: {"Content-Type": "multipart/form-data"}),
    );

    if (response.statusCode == 200) {
      return response.data['message'];
    } else {
      log('unsuccessfull req');
      return 'error';
    }
  }

  static Future<void> sendNotifcation(
      String toToken, String name, String content) async {
    final dio = Dio();

    String localUrl = 'http://13.125.68.71:5000/sendChat';

    FormData formData =
        FormData.fromMap({'fcm': toToken, 'name': name, 'content': content});

    dio.get(
      localUrl,
      data: formData,
      options: Options(headers: {"Content-Type": "multipart/form-data"}),
    );
  }

  static Future<String> generateToken(String roomid, int uid) async {
    final localUrl = 'http://13.125.68.71:5000/generate_agora_token/' + roomid;

    final dio = Dio();

    FormData formData = FormData.fromMap({
      'uid': uid,
    });

    print('pre response for generate token $url');

    final response = await dio.post(
      localUrl,
      data: formData,
      options: Options(headers: {"Content-Type": "multipart/form-data"}),
    );
    print('response: ${response}');

    if (response.statusCode == 200) {
      print('download: ${response.data['token']}');

      return response.data['token'];
    } else {
      log('unsuccessfull req');
      return 'error';
    }
  }

  static addUser(String id, String fromVoice, String toVoice, String fromMsg,
      String toMsg) {
    usersBox.put(
        id,
        Customer(
          id: id,
          transFromVoice: fromVoice,
          transToVoice: toVoice,
          transFromMsg: fromMsg,
          transToMsg: toMsg,
        ));
  }

  // static Future<void> getFirebaseMessagingToken() async {
  //   await firebaseMessaging.requestPermission();
  //   await firebaseMessaging.getToken().then((value) {
  //     if (value != null) String token = value;
  //   });
  // }
  //   void selectedImage( String myUserName) async {
  //   final ImagePicker _imagePicker = ImagePicker();
  //   XFile? _file = await _imagePicker.pickImage(source: ImageSource.gallery);

  //   if (_file == null) return;
  //   Reference referenceRoot = FirebaseStorage.instance.ref();
  //   Reference referenceDirImages = referenceRoot.child('images');
  //   Reference referenceImageToUpload = referenceDirImages.child(myUserName!);
  //   File img = File(_file.path);

  //   try {
  //     referenceImageToUpload.putFile(img);
  //     referenceImageToUpload.getDownloadURL();
  //   } catch (e) {
  //     print('upload image to firebase exception: $e');
  //   }

  //   myProfilePic = await referenceImageToUpload.getDownloadURL();
  //   _dataController.picUrl = myProfilePic!;
  //   // await DefaultCacheManager().emptyCache();
  //   print('uploaded its url :$myProfilePic, userid: $myId');
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(myId ?? _dataController.id)
  //       .update({"Photo": myProfilePic});
  //   setState(() {});
  //   // updateUser();
  // }
}
