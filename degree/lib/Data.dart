import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:http/http.dart' as http;

class Data {
  static Future<String> sendAudio(File file) async {
    final url = 'http://localhost:5000/todo';
    Map<String, File> request = {"file": file};

    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(Uri.parse(url),
        headers: headers, body: json.encode(request));
    Map<String, dynamic> responsePayload = json.decode(response.body);
    return 'hi';
  }
}
