class UserModel {
  String name = '', address = '';
  bool isStaff = false;

  UserModel({required this.name, required this.address});

  UserModel.fromJson(Map<String,dynamic> json) {
    address = json['address'];
    name = json['name'];
    isStaff = json['isStaff'] == null ? false : json['isStaff'] as bool;
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['name'] = this.name;
    data['isStaff'] = this.isStaff;
    return data;
  }
}