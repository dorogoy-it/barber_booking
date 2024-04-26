class ServiceModel {
  String name = '';
  String? docId = '';
  double price = 0;

  ServiceModel({required this.name, required this.price});

  ServiceModel.fromJson(Map<String,dynamic> json) {
    name = json['name'];
    price = json['price'] == null ? 0 : double.parse(json['price'].toString());

  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ServiceModel &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              price == other.price;

  @override
  int get hashCode => name.hashCode ^ price.hashCode;

  @override
  String toString() {
    return 'ServiceModel{price: $price, name: $name}';
  }
}