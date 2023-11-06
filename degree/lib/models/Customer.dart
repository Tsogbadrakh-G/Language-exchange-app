import 'package:hive/hive.dart';

@HiveType(typeId: 1, adapterName: 'CallAdapter')
class Customer {
  @HiveField(0)
  String id;

  @HiveField(1)
  String transFromVoice;

  @HiveField(2)
  String transToVoice;

  @HiveField(3)
  String transFromMsg;

  @HiveField(4)
  String transToMsg;

  Customer({
    required this.id,
    required this.transFromVoice,
    required this.transToVoice,
    required this.transFromMsg,
    required this.transToMsg,
  });
}

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final typeId = 1;

  @override
  Customer read(BinaryReader reader) {
    Customer model = Customer(
      id: reader.read(),
      transFromVoice: reader.read(),
      transToVoice: reader.read(),
      transFromMsg: reader.read(),
      transToMsg: reader.read(),
    );

    return model;
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer.write(obj.id);
    writer.write(obj.transFromVoice);
    writer.write(obj.transToVoice);
    writer.write(obj.transFromMsg);
    writer.write(obj.transToMsg);
  }
}
