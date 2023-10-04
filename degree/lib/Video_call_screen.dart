import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/Data.dart';
import 'package:degree/custom_source.dart';
import 'package:degree/service/database.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:random_string/random_string.dart';

const appId = "d565b44b98164c39b2b1855292b22dd2";
const token =
    "007eJxTYIhs3fZm3qrPrAzCTxauq/EWu32X9fBe/vcbHp6sPL1+lUClAkOKqZlpkolJkqWFoZlJsrFlklGSoYWpqZGlUZKRUUqK0eaj0qkNgYwMd+JSmBkZIBDEZ2EoSS0uYWAAANbZIRU=";
//const channel = "test_channel";

List<String> out_lans = [
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

class Video_call_screen extends StatefulWidget {
  final String channel, myUserName, username, from, to;
  const Video_call_screen(
      this.channel, this.myUserName, this.username, this.from, this.to,
      {Key? key})
      : super(key: key);

  @override
  State<Video_call_screen> createState() => _Video_call_screen();
}

class _Video_call_screen extends State<Video_call_screen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  int mute = 0;
  final audioPlayer = AudioPlayer();
  final dio = Dio();
  bool isRecording = false;
  bool exited = false;

  @override
  void initState() {
    super.initState();
    initAgora();
    listenForNewMessages();
  }

  void listenForNewMessages() {
    final CollectionReference messagesCollection = FirebaseFirestore.instance
        .collection('chatrooms/${widget.channel}/chats');

    messagesCollection.snapshots().listen((QuerySnapshot snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          // This message is newly added

          final messageData = change.doc.data() as Map<String, dynamic>;

          //  print('New Message: $messageData, $myUserName');

          log(' new message: ${messageData}, widget username: ${widget.username}');
          if (exited) {
            updateChatReadState(messageData["id"]);
          } else if (messageData["type"] == "audio" &&
              messageData["sendBy"] == widget.username &&
              messageData["read"] == 0) {
            downloadAndPlayAudio(messageData["url"], messageData["id"]);
          }

          // Process and display the new message as needed
        }
      });
    });
  }

  downloadAndPlayAudio(String url, chatId) async {
    log('audio play');
    final res =
        await dio.get(url, options: Options(responseType: ResponseType.bytes));
    print('download: ${res.data}');

    final audioPlayer = AudioPlayer();
    log('1');
    await audioPlayer.setAudioSource(CustomSource(res.data));
    log('2');

    await audioPlayer.load();
    log('3');
    await audioPlayer.play();
    log('4');
    updateChatReadState(chatId);
  }

  updateChatReadState(String chatId) async {
    try {
      final chatPairRef = FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.channel)
          .collection('chats')
          .doc(chatId);
      await chatPairRef.update({
        'read': 1,
      });
    } catch (e) {
      print('Error updating chat pair: $e');
    }
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      const RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          logConfig: LogConfig(level: LogLevel.logLevelError)),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) {
          log('$err, $msg');
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.enableAudio();
    await _engine.muteLocalAudioStream(true);

    await _engine.joinChannel(
      token: token,
      channelId: "test",
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    log('from ${widget.from}, to: ${widget.to}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                  child: !isRecording
                      ? _localUserJoined
                          ? AgoraVideoView(
                              controller: VideoViewController(
                                rtcEngine: _engine,
                                canvas: const VideoCanvas(uid: 0),
                              ),
                            )
                          : const CircularProgressIndicator()
                      : Text(
                          'Recording in Progress',
                          style: TextStyle(fontSize: 20),
                        )),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              child: Icon(Icons.music_note),
              foregroundColor: mute % 2 == 1 ? Colors.red : Colors.white,
              onPressed: () async {
                mute++;
                log('click $mute');
                if (mute % 2 == 0) {
                  await _engine.muteLocalAudioStream(true);
                  await _engine.stopAudioRecording();

                  Directory tempDir = await getTemporaryDirectory();
                  String record = '${tempDir.absolute.path}/record.wav';

                  log('recorded file: $record');
                  // Uint8List hha = await File(record).readAsBytesSync();

                  setState(() {});

                  var val = await Data.sendAudio(
                      record,
                      "English",
                      "Halh Mongolian",
                      "S2TT (Speech to Text translation)",
                      widget.channel,
                      widget.myUserName);
                  // var val = await Data.sendAudio(record, "English", "German",
                  //     "S2ST (Speech to Speech translation)");
                  await sendAudioLink(val);

                  // final audioPlayer = AudioPlayer();
                  // await audioPlayer.setAudioSource(CustomSource(val));

                  // await audioPlayer.load();

                  // audioPlayer.play();
                } else {
                  await _engine.muteLocalAudioStream(false);
                  Directory tempDir = await getTemporaryDirectory();
                  String record = '${tempDir.absolute.path}/record.wav';
                  await File(record).create(exclusive: false, recursive: false);

                  _engine.startAudioRecording(
                    AudioRecordingConfiguration(
                      sampleRate: 32000,
                      filePath: record,
                      fileRecordingType:
                          AudioFileRecordingType.audioFileRecordingMic,
                      recordingChannel: 1,
                      quality:
                          AudioRecordingQualityType.audioRecordingQualityMedium,
                      encode: true,
                    ),
                  );

                  setState(() {});
                }
              },
            ),
          )
        ],
      ),
    );
  }

  sendAudioLink(String val) async {
    String messageId = randomAlphaNumeric(10);

    Map<String, dynamic> messageInfoMap = {
      "id": messageId,
      "type": "audio",
      "url": val,
      "sendBy": widget.myUserName,
      "read": 0
    };

    DatabaseMethods().addMessage(widget.channel, messageId, messageInfoMap);
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: "test")),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _engine.leaveChannel();
    _engine.release();
    super.dispose();

    exited = true;
  }
}
