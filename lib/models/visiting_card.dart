class VisitingCard {
  final String id;
  String nickname;
  String name;
  String designation;
  String company;
  String? photoUrl;   // remote URL from server after upload
  String? photoPath;  // local file path (before upload / offline)
  String email1;
  String email2;
  String phone1;
  String phone2;
  String website;
  String address;
  int templateIndex;
  DateTime createdAt;

  VisitingCard({
    required this.id,
    required this.nickname,
    required this.name,
    required this.designation,
    required this.company,
    this.photoUrl,
    this.photoPath,
    required this.email1,
    this.email2 = '',
    required this.phone1,
    this.phone2 = '',
    this.website = '',
    this.address = '',
    this.templateIndex = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'name': name,
        'designation': designation,
        'company': company,
        'photoUrl': photoUrl,
        'email1': email1,
        'email2': email2,
        'phone1': phone1,
        'phone2': phone2,
        'website': website,
        'address': address,
        'templateIndex': templateIndex,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VisitingCard.fromJson(Map<String, dynamic> json) => VisitingCard(
        id: json['id'] ?? '',
        nickname: json['nickname'] ?? '',
        name: json['name'] ?? '',
        designation: json['designation'] ?? '',
        company: json['company'] ?? '',
        photoUrl: json['photoUrl'] ?? json['photo_url'],
        email1: json['email1'] ?? '',
        email2: json['email2'] ?? '',
        phone1: json['phone1'] ?? '',
        phone2: json['phone2'] ?? '',
        website: json['website'] ?? '',
        address: json['address'] ?? '',
        templateIndex: json['templateIndex'] ?? json['template_index'] ?? 0,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
      );

  VisitingCard copyWith({
    String? nickname,
    String? name,
    String? designation,
    String? company,
    String? photoUrl,
    String? photoPath,
    String? email1,
    String? email2,
    String? phone1,
    String? phone2,
    String? website,
    String? address,
    int? templateIndex,
  }) =>
      VisitingCard(
        id: id,
        nickname: nickname ?? this.nickname,
        name: name ?? this.name,
        designation: designation ?? this.designation,
        company: company ?? this.company,
        photoUrl: photoUrl ?? this.photoUrl,
        photoPath: photoPath ?? this.photoPath,
        email1: email1 ?? this.email1,
        email2: email2 ?? this.email2,
        phone1: phone1 ?? this.phone1,
        phone2: phone2 ?? this.phone2,
        website: website ?? this.website,
        address: address ?? this.address,
        templateIndex: templateIndex ?? this.templateIndex,
        createdAt: createdAt,
      );

  /// Returns a photo widget-ready image URL or null
  String? get effectivePhotoUrl => photoUrl?.isNotEmpty == true ? photoUrl : null;
}