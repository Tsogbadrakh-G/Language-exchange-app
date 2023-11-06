// ignore: file_names
class Chat {
  String id;

  String message;

  String channel;

  String chatuserName;

  String callStatus;

  String time;

  DateTime officialTime;

  Chat(
      {required this.id,
      required this.channel,
      required this.message,
      required this.chatuserName,
      required this.callStatus,
      required this.time,
      required this.officialTime});
}
