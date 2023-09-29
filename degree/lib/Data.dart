import 'dart:developer';
import 'package:dio/dio.dart';

class Data {
  List<String> inputLanguages = [];

  List<String> outputLanguages = [];
  static Future<dynamic> sendAudio(
      String path, String from, String to, String tranlsation) async {
    final url = 'http://51.20.44.63:5000/todo';
    //final url = 'http://192.168.1.74:5000/todo';
    final dio = Dio();

    FormData formData = FormData.fromMap({
      'type': "audio",
      'audio': await MultipartFile.fromFile(path, filename: 'record.wav'),
      'input': from,
      'output': to,
      'translation': tranlsation,
    });

    log('pre res ');

    final response = await dio.post(
      url,
      data: formData,
      options: Options(headers: {"Content-Type": "multipart/form-data"}),
    );
    log('response: ${response}');
    // dio.download(response.data[''], savePath)

    if (response.statusCode == 200) {
      //translated audio file URL on the server
      return response.data['message'];
    } else {
      log('unsuccessfull req');
      return 'error';
    }
  }

  static Future<String> sendText(String text, String from, String to) async {
    final url = 'http://51.20.44.63:5000/todo';
    //final url = 'http://192.168.1.101:5000/todo';
    final dio = Dio();

    FormData formData = FormData.fromMap({
      'type': "text",
      'text': text,
      'input': from,
      'output': to,
    });

    log('pre res for text ');

    final response = await dio.post(
      url,
      data: formData,
      options: Options(headers: {"Content-Type": "multipart/form-data"}),
    );
    log('response: ${response}');
    // dio.download(response.data[''], savePath)

    if (response.statusCode == 200) {
      //final res = await dio.get(response.data['message'],
      //  options: Options(responseType: ResponseType.plain));
      print('download: ${response.data['message']}');
      // Map<String, dynamic> responsePayload = json.decode(response.data);
      //log(responsePayload["res"]);

      return response.data['message'];
    } else {
      log('unsuccessfull req');
      return 'error';
    }
  }
}
