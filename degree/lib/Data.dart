import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:http/http.dart' as http;

class Data {
  static Future<String> sendAudio(String req) async {
    final url = 'http://localhost:5000/todo';
    Map<String, dynamic> request = {"file": req};

    final headers = {
      'Content-Type':
          'multipart/form-data; boundary=<calculated when request is sent>'
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: json.encode(request));
    Map<String, dynamic> responsePayload = json.decode(response.body);
    return responsePayload["res"];
  }
}
