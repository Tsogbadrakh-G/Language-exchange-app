import 'dart:developer';

import 'package:degree/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Video Call With Agora',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
//         useMaterial3: true,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

const appId = "d565b44b98164c39b2b1855292b22dd2";
const token =
    "007eJxTYPhf7frS/bFKVrjhzdqKl0qqz095HOlf/VY1QZEl5iKj2h4FhhRTM9MkE5MkSwtDM5NkY8skoyRDC1NTI0ujJCOjlBSjlt3MqQ2BjAwR341ZGBkgEMTnYShJLS6JT85IzMtLzWFgAAA9yyHP";
const channel = "test_channel";

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  int mute = 0;

  AudioRecordingConfiguration config = AudioRecordingConfiguration(
    filePath: '../../ai_speech_translator/audio/input.wav',
  );

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
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

    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
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
                child: mute % 2 == 0
                    ? _localUserJoined
                        ? AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _engine,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          )
                        : const CircularProgressIndicator()
                    : Offstage(),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                mute++;
                log('click $mute');
                if (mute % 2 == 0) {
                  setState(() {});
                  _engine.stopAudioRecording();
                  log('stopped to record');
                } else {
                  setState(() {});
                  _engine.startAudioRecording(config);
                  log('started to record');
                }
              },
            ),
          )
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
