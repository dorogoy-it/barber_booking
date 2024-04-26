class UserModel {
  String name = '', address = '', phone = '', id = '';
  bool isStaff = false, isAdmin = false;

  UserModel({required this.name, required this.address, required this.phone, required this.id});

  UserModel.fromJson(Map<String,dynamic> json) {
    address = json['address'];
    name = json['name'];
    phone = json['phone'];
    id = json['id'];
    isStaff = json['isStaff'] == null ? false : json['isStaff'] as bool;
    isAdmin = json['isAdmin'] == null ? false : json['isAdmin'] as bool;
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['name'] = name;
    data['phone'] = phone;
    data['id'] = id;
    data['isStaff'] = isStaff;
    data['isAdmin'] = isAdmin;
    return data;
  }
}