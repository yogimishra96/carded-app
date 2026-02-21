class CollectedCard {
  final String id;
  String autoName;
  String name;
  String designation;
  String company;
  String email1;
  String email2;
  String phone1;
  String phone2;
  String website;
  String address;
  int templateIndex;
  // Editable fields
  String category;
  String leadType;
  String remarks;
  DateTime scannedAt;

  CollectedCard({
    required this.id,
    required this.autoName,
    required this.name,
    required this.designation,
    required this.company,
    required this.email1,
    this.email2 = '',
    required this.phone1,
    this.phone2 = '',
    this.website = '',
    this.address = '',
    this.templateIndex = 0,
    this.category = '',
    this.leadType = '',
    this.remarks = '',
    required this.scannedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'autoName': autoName,
        'name': name,
        'designation': designation,
        'company': company,
        'email1': email1,
        'email2': email2,
        'phone1': phone1,
        'phone2': phone2,
        'website': website,
        'address': address,
        'templateIndex': templateIndex,
        'category': category,
        'leadType': leadType,
        'remarks': remarks,
        'scannedAt': scannedAt.toIso8601String(),
      };

  factory CollectedCard.fromJson(Map<String, dynamic> json) => CollectedCard(
        id: json['id'],
        autoName: json['autoName'],
        name: json['name'],
        designation: json['designation'],
        company: json['company'],
        email1: json['email1'],
        email2: json['email2'] ?? '',
        phone1: json['phone1'],
        phone2: json['phone2'] ?? '',
        website: json['website'] ?? '',
        address: json['address'] ?? '',
        templateIndex: json['templateIndex'] ?? 0,
        category: json['category'] ?? '',
        leadType: json['leadType'] ?? '',
        remarks: json['remarks'] ?? '',
        scannedAt: DateTime.parse(json['scannedAt']),
      );
}
