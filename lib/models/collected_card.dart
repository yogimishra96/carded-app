enum ScanType { carded, photoCard, qrOther }

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
  int    templateIndex;
  String category;
  String leadType;
  String remarks;
  // New fields
  ScanType scanType;
  String   cardImageUrl; // physical card photo URL
  String   qrRawData;   // raw QR string for qr_other
  String   photoUrl;    // profile photo (carded type)
  DateTime scannedAt;

  CollectedCard({
    required this.id,
    required this.autoName,
    required this.name,
    this.designation = '',
    this.company     = '',
    this.email1      = '',
    this.email2      = '',
    this.phone1      = '',
    this.phone2      = '',
    this.website     = '',
    this.address     = '',
    this.templateIndex = 0,
    this.category    = '',
    this.leadType    = '',
    this.remarks     = '',
    this.scanType    = ScanType.carded,
    this.cardImageUrl = '',
    this.qrRawData   = '',
    this.photoUrl    = '',
    required this.scannedAt,
  });

  factory CollectedCard.fromJson(Map<String, dynamic> j) {
    ScanType st;
    switch (j['scanType'] ?? 'carded') {
      case 'photo_card': st = ScanType.photoCard; break;
      case 'qr_other':   st = ScanType.qrOther;   break;
      default:           st = ScanType.carded;
    }
    return CollectedCard(
      id:            j['id'] ?? '',
      autoName:      j['autoName'] ?? '',
      name:          j['name'] ?? '',
      designation:   j['designation'] ?? '',
      company:       j['company'] ?? '',
      email1:        j['email1'] ?? '',
      email2:        j['email2'] ?? '',
      phone1:        j['phone1'] ?? '',
      phone2:        j['phone2'] ?? '',
      website:       j['website'] ?? '',
      address:       j['address'] ?? '',
      templateIndex: j['templateIndex'] ?? 0,
      category:      j['category'] ?? '',
      leadType:      j['leadType'] ?? '',
      remarks:       j['remarks'] ?? '',
      scanType:      st,
      cardImageUrl:  j['cardImageUrl'] ?? '',
      qrRawData:     j['qrRawData'] ?? '',
      photoUrl:      j['photoUrl'] ?? '',
      scannedAt:     DateTime.tryParse(j['scannedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'autoName': autoName, 'name': name,
    'designation': designation, 'company': company,
    'email1': email1, 'email2': email2,
    'phone1': phone1, 'phone2': phone2,
    'website': website, 'address': address,
    'templateIndex': templateIndex,
    'category': category, 'leadType': leadType, 'remarks': remarks,
    'scanType': scanType.name,
    'cardImageUrl': cardImageUrl, 'qrRawData': qrRawData, 'photoUrl': photoUrl,
    'scannedAt': scannedAt.toIso8601String(),
  };

  // Display helpers
  String get scanTypeLabel {
    switch (scanType) {
      case ScanType.carded:    return 'Carded';
      case ScanType.photoCard: return 'Photo Card';
      case ScanType.qrOther:   return 'QR Code';
    }
  }

  bool get isUrl {
    if (scanType != ScanType.qrOther) return false;
    return qrRawData.startsWith('http://') || qrRawData.startsWith('https://');
  }
}