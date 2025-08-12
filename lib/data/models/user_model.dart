class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? json['username'],
      email: json['email'],
      phone: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phone,
    };
  }
}
