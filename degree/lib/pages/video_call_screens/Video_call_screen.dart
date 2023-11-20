import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/service/data_api.dart';
import 'package:degree/service/database.dart';
import 'package:degree/service/Controllers/listenController.dart';
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

class VideoCallScreen extends StatefulWidget {
  final String channel, myUserName, username, from, to, channelToken;
  final int uid;
  const VideoCallScreen(this.channel, this.myUserName, this.username, this.from,
      this.to, this.channelToken, this.uid,
      {Key? key})
      : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreen();
}

class _VideoCallScreen extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  int mute = 0;
  final audioPlayer = AudioPlayer();
  final dio = Dio();
  bool isRecording = false;
  final ListenerController _listenerController = Get.find();

  @override
  void initState() {
    //print('init video call screen');
    _listenerController.exitedForEachChannel_Voice[widget.username] = false;
    initAgora();
    //_dataController.sendJoinRequest(widget.channel);

    super.initState();
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
      await _engine.joinChannel(
        token: widget.channelToken,
        channelId: widget.channel,
        uid: widget.uid,
        options: const ChannelMediaOptions(),
      );
    } catch (e) {
      log('exception in agora: $e');
    }
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    print('Video call screen');
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //       onPressed: () {
      //         _dataController.exitedForEachChannel_Voice[widget.username] =
      //             true;
      //         Get.back();
      //       },
      //       icon: Icon(Icons.arrow_back_ios)),
      //   title: const Text('Agora Video Call'),
      // ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(),
                  image: const DecorationImage(
                      image: AssetImage('assets/images/ic_splash.png'),
                      fit: BoxFit.fitWidth)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                  color: const Color(0xff000000).withOpacity(0.9)),
              child: _remoteVideo(),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 120, 0, 0),
              child: SizedBox(
                width: 120,
                height: 200,
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
                        : const Text(
                            'Recording in Progress',
                            style: TextStyle(fontSize: 20),
                          )),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 100,
            child: Transform.scale(
              scale: 1.2,
              child: FloatingActionButton(
                heroTag: 'end  call',
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                child: const Icon(Icons.call_end),
                onPressed: () async {
                  _listenerController
                      .exitedForEachChannel_Voice[widget.username] = true;
                  _listenerController.sendEndCall(widget.channel);
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Transform.scale(
              scale: 1.2,
              child: FloatingActionButton(
                heroTag: 'enable voice',
                backgroundColor: Colors.white70,
                foregroundColor: mute % 2 == 1 ? Colors.red : Colors.black,
                onPressed: () async {
                  mute++;
                  print('click $mute ${widget.from} ${widget.to}');
                  if (mute % 2 == 0) {
                    await _engine.muteLocalAudioStream(true);

                    if (widget.from != widget.to) {
                      await _engine.stopAudioRecording();

                      Directory tempDir = await getTemporaryDirectory();
                      String record = '${tempDir.absolute.path}/record.wav';

                      // print('recorded file: $record');
                      print('from ${widget.from}, to: ${widget.to}');
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
                    } else {
                      setState(() {});
                    }
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
                child: const Icon(Icons.keyboard_voice_outlined),
              ),
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

    //  print('video time in vidoe call screen: $formattedDate, $hour');
    Map<String, dynamic> messageInfoMap = {
      "id": messageId,
      "type": "audio",
      "url": val,
      "message": "",
      "sendBy": widget.myUserName,
      "read": false,
      "time": FieldValue.serverTimestamp(),
      "ts": "$hour , $formattedDate",
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
      return Padding(
          padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
          child: Column(
            children: [
              Text(
                widget.username,
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'Nunito', fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Холбогдож байна...',
                style: TextStyle(
                    color: Color.fromARGB(255, 143, 143, 150),
                    fontFamily: 'Nunito'),
                textAlign: TextAlign.center,
              )
            ],
          ));
    }
  }

  @override
  Future<void> dispose() async {
    leaveChannel();
    super.dispose();
  }

  Future<void> leaveChannel() async {
    await _engine.leaveChannel();
    _engine.release();
    _listenerController.exitedForEachChannel_Voice[widget.username] = true;
  }
}
