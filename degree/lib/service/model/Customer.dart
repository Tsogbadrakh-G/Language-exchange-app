import 'package:hive/hive.dart';

@HiveType(typeId: 1, adapterName: 'CallAdapter')
class Customer {
  @HiveField(0)
  String id;

  @HiveField(1)
  String trans_from_voice;

  @HiveField(2)
  String trans_to_voice;

  @HiveField(3)
  String trans_from_msg;

  @HiveField(4)
  String trans_to_msg;

  Customer({
    required this.id,
    required this.trans_from_voice,
    required this.trans_to_voice,
    required this.trans_from_msg,
    required this.trans_to_msg,
  });
}

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final typeId = 1;

  @override
  Customer read(BinaryReader reader) {
    Customer model = Customer(
      id: reader.read(),
      trans_from_voice: reader.read(),
      trans_to_voice: reader.read(),
      trans_from_msg: reader.read(),
      trans_to_msg: reader.read(),
    );

    return model;
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer.write(obj.id);
    writer.write(obj.trans_from_voice);
    writer.write(obj.trans_to_voice);
    writer.write(obj.trans_from_msg);
    writer.write(obj.trans_to_msg);
  }
}
