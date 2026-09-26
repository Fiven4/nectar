class UserModel {
  final String id;
  final String login;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.login,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'login': login.trim(),
      'loginNormalized': login.trim().toLowerCase(),
      'displayName': name.trim(),
      'email': email.trim().toLowerCase(),
      'emailNormalized': email.trim().toLowerCase(),
      'phoneNumber': phoneNumber.trim(),
      'role': role,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'] ?? json['id'] ?? '',
      login: json['login'] ?? '',
      name: json['displayName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'buyer',
      photoUrl: json['photoUrl'],
    );
  }
}
