import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:degree/Data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:record/record.dart';
// import 'package:flutter_sound/flutter_sound.dart';

const appId = "d565b44b98164c39b2b1855292b22dd2";
const token =
    "007eJxTYDB2cdCZpmEwb8/sX15idn5V0fc/1BlrrrY2DL98YieT9AoFhhRTM9MkE5MkSwtDM5NkY8skoyRDC1NTI0ujJCOjlBQj14PsqQ2BjAwSx1tZGBkgEMTnYShJLS6JT85IzMtLzWFgAABuJh+p";
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
  //final audioPlayer = AudioPlayer();
  //final audioRecord = Record();
  bool isRecording = false;
  //String? audioPath = '../../ai_speech_translator/audio/input.wav';

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

  // Future<void> startRecording() async {

  //   try {
  //     if (await audioRecord.hasPermission()) {
  //       await audioRecord.start();
  //       setState(() {
  //         isRecording = true;
  //       });
  //     }
  //   } catch (e) {
  //     log('Error start Recording : $e');
  //   }
  // }

  // Future<void> stopRecording() async {
  //   print('hello is $isRecording');
  //   try {
  //     String? path = await audioRecord.stop();
  //     log('output : $path');
  //     isRecording = false;
  //   } catch (e) {
  //     print('Error stopping recording: $e');
  //   }

  // }

  // Future<void> playRecording(Uint8List hha) async {
  //   try {
  //     Source urlSource = BytesSource(hha);
  //     // Source urlSource = UrlSource(audioPath!);

  //     await audioPlayer.play(urlSource);
  //     log('playing path $audioPath');
  //   } catch (e) {
  //     log('Error Play Recording : $e');
  //   }
  // }

  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
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
                  await _engine.stopAudioRecording();
                  Directory tempDir = await getTemporaryDirectory();
                  String record = '${tempDir.absolute.path}/record.aac';

                  log('recorded file: $record');
                  Uint8List hha = await File(record).readAsBytes();

                  File req = await File(record);
                  Data.sendAudio(req);

                  print('hha ${hha.length}');
                  // print('hha $hha');

                  assetsAudioPlayer.open(Audio.file(record),
                      showNotification: true);

                  assetsAudioPlayer.play();

                  // final player = AudioPlayer();
                  // player.play(UrlSource(record));

                  // playRecording(hha);
                  // File(record);
                  // Source urlSource =BytesSource(audioPath!);
                  // await stopRecording();
                  // log('stopped recording');
                  // if (!isRecording && audioPath != null) {
                  //   await playRecording();
                  // }
                  setState(() {});
                } else {
                  Directory tempDir = await getTemporaryDirectory();
                  String record = '${tempDir.absolute.path}/record.aac';
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

  @override
  void dispose() {
    assetsAudioPlayer.dispose();
    super.dispose();
  }
}
