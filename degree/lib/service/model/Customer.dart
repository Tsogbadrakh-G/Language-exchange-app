import 'package:hive/hive.dart';

@HiveType(typeId: 1, adapterName: 'CallAdapter')
class Customer {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String username;

  @HiveField(3)
  String picUrl;

  @HiveField(4)
  String SearchKey;

  @HiveField(5)
  String email;

  Customer(
      {required this.id,
      required this.name,
      required this.username,
      required this.picUrl,
      required this.SearchKey,
      required this.email});
}

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final typeId = 1;

  @override
  Customer read(BinaryReader reader) {
    Customer model = Customer(
        id: reader.read(),
        name: reader.read(),
        username: reader.read(),
        picUrl: reader.read(),
        SearchKey: reader.read(),
        email: reader.read());

    return model;
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.username);
    writer.write(obj.picUrl);
    writer.write(obj.SearchKey);
    writer.write(obj.email);
  }
}
