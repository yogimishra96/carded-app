class AppUser {
  final String id;
  String fullName;
  String email;
  String phone;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] ?? '',
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
      );
}
