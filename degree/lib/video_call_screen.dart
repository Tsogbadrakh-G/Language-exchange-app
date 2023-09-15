import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:degree/home_screen.dart';
import 'package:flutter/material.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

//import 'package:agora_rtc_engine/src/' as RtcLocalView;
class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  AudioRecordingConfiguration config = AudioRecordingConfiguration(
      filePath: '../../ai_speech_translator/audio/input.wav',
      fileRecordingType: AudioFileRecordingType.audioFileRecordingMic);

  final _client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
          appId: 'd565b44b98164c39b2b1855292b22dd2',
          channelName: 'test_channel',
          tempToken:
              '007eJxTYPhf7frS/bFKVrjhzdqKl0qqz095HOlf/VY1QZEl5iKj2h4FhhRTM9MkE5MkSwtDM5NkY8skoyRDC1NTI0ujJCOjlBSjlt3MqQ2BjAwR341ZGBkgEMTnYShJLS6JT85IzMtLzWFgAAA9yyHP',
          // uid: 12,
          username: 'ts'),
      enabledPermission: [
        Permission.camera,
        Permission.microphone,
      ]);

  Future<void> _initializeAgora() async {
    await _client.initialize();
    _client.engine.startAudioRecording(config);
    log('recording');
  }

  @override
  void dispose() {
    log('recorded');
    super.dispose();
  }

  @override
  void initState() {
    log('here');
    _initializeAgora();
    super.initState();
  }

  // @override
  // Widget build(BuildContext context) {
  //   //String callType = _callKitController.state.callData.isNotEmpty ? _callKitController.state.callData['type'] : Get.arguments['type'];

  //   return WillPopScope(
  //     onWillPop: () async => false,
  //     child: Scaffold(
  //       backgroundColor: Colors.black,
  //       body: Stack(
  //         children: [
  //           Align(
  //             alignment: Alignment.center,
  //             child: Image.asset('images/bg_call_blur.png'),
  //           ),
  //           _rtcCall(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _rtcCall() {
  //   return Stack(
  //     children: [
  //       Column(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           _renderVideo(),
  //         ],
  //       ),
  //       Positioned(
  //           bottom: 40,
  //           left: 0,
  //           right: 0,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               const SizedBox(width: 32.0),
  //               _muteButton(),
  //             ],
  //           ))
  //     ],
  //   );
  // }

  // void _muteButtonHandler() async {
  //   log('hi');
  // }

  // Widget _muteButton() {
  //   return GestureDetector(
  //     onTap: () => _muteButtonHandler(),
  //     child: Container(
  //       height: 64,
  //       width: 64,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: Center(
  //         child: Image.asset(
  //           'images/ic_mute.png',
  //           color: Colors.white.withOpacity(0.6),
  //           width: 32,
  //           height: 32,
  //           fit: BoxFit.scaleDown,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _renderVideo() {
  //   return Expanded(
  //     child: Stack(
  //       children: [
  //         _renderRemoteVideo(),
  //         Positioned(
  //           top: 10,
  //           child: Align(
  //             alignment: Alignment.topLeft,
  //             child: SizedBox(
  //               width: 120,
  //               height: 200,
  //               // child: Visibility(

  //               //   child: _renderLocalVideo(),
  //               // ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _renderRemoteVideo() {
  //   return AgoraVideoViewer(
  //     client: _client,
  //     showNumberOfUsers: true,
  //     layoutType: Layout.floating,
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: GestureDetector(
            child: Text('Here voice record'),
            onTap: () {
              log('message');
            },
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(
                client: _client,
                showNumberOfUsers: true,
                layoutType: Layout.floating,
              ),
              AgoraVideoButtons(
                client: _client,
                enabledButtons: [
                  BuiltInButtons.toggleCamera,
                  BuiltInButtons.switchCamera,
                  BuiltInButtons.callEnd,
                  BuiltInButtons.toggleMic,
                ],
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _client.engine.stopAudioRecording();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
