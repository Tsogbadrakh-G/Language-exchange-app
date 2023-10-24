import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/DataAPI.dart';
import 'package:degree/custom_source.dart';
import 'package:degree/service/Controller.dart';
import 'package:degree/service/database.dart';
import 'package:degree/service/model/somni_alert.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:random_string/random_string.dart';

const appId = "d565b44b98164c39b2b1855292b22dd2";

class Video_call_screen extends StatefulWidget {
  final String channel, myUserName, username, from, to, channelToken;
  final int uid;
  const Video_call_screen(this.channel, this.myUserName, this.username,
      this.from, this.to, this.channelToken, this.uid,
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

  DataController _dataController = Get.find();

  @override
  void initState() {
    print('init video call screen');
    _dataController.exitedForEachChannel_Voice[widget.username] = false;
    initAgora();
    listenForNewMessages();
    super.initState();
  }

  void listenForNewMessages() {
    final CollectionReference messagesCollection = FirebaseFirestore.instance
        .collection('chatrooms/${widget.channel}/chats');

    messagesCollection.snapshots().listen((QuerySnapshot snapshot) {
      snapshot.docChanges.forEach((change) async {
        if (change.type == DocumentChangeType.added) {
          // This message is newly added

          final messageData = change.doc.data() as Map<String, dynamic>;
          bool exited =
              _dataController.exitedForEachChannel_Voice[widget.username] ??
                  true;
          print(
              'new message: ${messageData}, widget username: ${widget.username}, exited: ${exited}');

          await SomniAlerts.alertBoxVertical(
            titleWidget: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                ' goal ',
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
                  textScaleFactor: MediaQuery.of(Get.context!).textScaleFactor,
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Та',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w400),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'k ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'дугаарт '),
                      TextSpan(
                          text: 'stat ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'цагт залгах сэрүүлэг тохируулсан байна.'),
                    ],
                  )),
            ),
            button1: () {
              Get.back();
            },
            button2: () {
              Get.back();
            },
            imgAsset: 'alert/alert_reminder',
            button1Text: '🤙 ',
            button2Text: '😴 ',
          );
          if (messageData["type"] == "audio" && exited) {
            updateChatReadState(messageData["id"], false, true);
          } else if (messageData["type"] == "audio" &&
              messageData["sendBy"] == widget.username &&
              messageData["missed"] == false &&
              messageData["read"] == false) {
            downloadAndPlayAudio(messageData["url"], messageData["id"]);
          }

          // Process and display the new message as needed
        }
      });
    });
  }

  downloadAndPlayAudio(String url, String chatId) async {
    log('audio play');
    final res =
        await dio.get(url, options: Options(responseType: ResponseType.bytes));
    print('download: ${res.data}');

    final audioPlayer = AudioPlayer();

    await audioPlayer.setAudioSource(CustomSource(res.data));

    await audioPlayer.load();
    log('3');
    await audioPlayer.play();
    log('4');
    updateChatReadState(chatId, true, false);
  }

  updateChatReadState(String chatId, bool read, bool missed) async {
    print('update data: id-$chatId, read- $read, miss- $missed');
    try {
      final chatPairRef = FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.channel)
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

  Future<void> initAgora() async {
    // retrieve permissions

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
    try {
      // print('token ${widget.channelToken}');
      // print('token ${widget.channel}');
      await _engine.joinChannel(
        token: widget.channelToken,
        channelId: widget.channel,
        uid: widget.uid,
        options: const ChannelMediaOptions(),
      );
    } catch (e) {
      print('exception in agora: $e');
    }
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    //  print('from ${widget.from}, to: ${widget.to} in Video call screen');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              _dataController.exitedForEachChannel_Voice[widget.username] =
                  true;
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios)),
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
                print('click $mute');
                if (mute % 2 == 0) {
                  await _engine.muteLocalAudioStream(true);

                  if (widget.from != widget.to) {
                    await _engine.stopAudioRecording();

                    Directory tempDir = await getTemporaryDirectory();
                    String record = '${tempDir.absolute.path}/record.wav';

                    print('recorded file: $record');
                    setState(() {});
                    String val;
                    if (widget.to == "Halh Mongolian") {
                      val = await Data.sendAudio(
                          record,
                          widget.from,
                          "Halh Mongolian",
                          "S2TT (Speech to Text translation)",
                          widget.channel,
                          widget.myUserName);
                    } else {
                      val = await Data.sendAudio(
                          record,
                          widget.from,
                          widget.to,
                          "S2ST (Speech to Speech translation)",
                          widget.channel,
                          widget.myUserName);
                    }

                    sendAudioLink(val);
                  } else
                    setState(() {});
                } else {
                  await _engine.muteLocalAudioStream(false);

                  if (widget.from != widget.to) {
                    Directory tempDir = await getTemporaryDirectory();
                    String record = '${tempDir.absolute.path}/record.wav';
                    await File(record)
                        .create(exclusive: false, recursive: false);

                    _engine.startAudioRecording(
                      AudioRecordingConfiguration(
                        sampleRate: 32000,
                        filePath: record,
                        fileRecordingType:
                            AudioFileRecordingType.audioFileRecordingMic,
                        recordingChannel: 1,
                        quality: AudioRecordingQualityType
                            .audioRecordingQualityMedium,
                        encode: true,
                      ),
                    );
                  }

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
    DateTime now = DateTime.now();
    String formattedDate = DateFormat.yMd().format(now);
    String hour = DateFormat.Hm().format(now);

    print('video time in vidoe call screen: $formattedDate, $hour');
    Map<String, dynamic> messageInfoMap = {
      "id": messageId,
      "type": "audio",
      "url": val,
      "message": "",
      "sendBy": widget.myUserName,
      "read": false,
      "time": FieldValue.serverTimestamp(),
      "ts": hour + " , " + formattedDate,
      "missed": false
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
            connection: RtcConnection(channelId: widget.channel)),
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

    _dataController.exitedForEachChannel_Voice[widget.username] = true;
    super.dispose();
  }
}
