import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/visiting_card.dart';
import '../models/collected_card.dart';
import 'api_client.dart';

class CardsService {
  static CardsService? _instance;
  static CardsService get instance => _instance ??= CardsService._();
  CardsService._();

  static const int maxCards = 5;

  // ─── My Cards ─────────────────────────────────────────────

  Future<List<VisitingCard>> getMyCards() async {
    final res = await ApiClient.instance.get('/cards');
    if (res.success) {
      final list = res.data['cards'] as List<dynamic>;
      return list.map((e) => VisitingCard.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // ─── Save Card + Photo ────────────────────────────────────
  //
  // Flow for NEW card:
  //   1. POST /cards          → card created, id milta hai
  //   2. POST /cards/:id/photo → Cloudinary pe upload, photo_url DB mein save
  //
  // Flow for EDIT card:
  //   1. PUT /cards/:id       → card updated
  //   2. POST /cards/:id/photo → sirf agar nayi photo pick ki ho

  Future<CardResult> saveCard(VisitingCard card, {File? photo}) async {
    // Step 1: Card data save karo (create ya update)
    CardResult result;
    if (card.id.isEmpty) {
      result = await _createCard(card);
    } else {
      result = await _updateCard(card);
    }

    if (!result.success || result.card == null) return result;

    // Step 2: Photo upload karo (card.id ab guaranteed exist karta hai)
    if (photo != null) {
      final photoUrl = await uploadPhoto(result.card!.id, photo);
      if (photoUrl != null) {
        return CardResult(
          success: true,
          card: result.card!.copyWith(photoUrl: photoUrl),
        );
      }
      // Photo upload fail — card toh ban gaya, non-fatal
    }

    return result;
  }

  Future<CardResult> _createCard(VisitingCard card) async {
    final res = await ApiClient.instance.post('/cards', card.toJson());
    if (res.success) {
      return CardResult(
        success: true,
        card: VisitingCard.fromJson(res.data['card'] as Map<String, dynamic>),
      );
    }
    if (res.statusCode == 403) {
      return CardResult(success: false, message: res.message, isLimitReached: true);
    }
    return CardResult(success: false, message: res.message ?? 'Failed to create card. Please try again.');
  }

  Future<CardResult> _updateCard(VisitingCard card) async {
    final res = await ApiClient.instance.put('/cards/${card.id}', card.toJson());
    if (res.success) {
      return CardResult(
        success: true,
        card: VisitingCard.fromJson(res.data['card'] as Map<String, dynamic>),
      );
    }
    return CardResult(success: false, message: res.message ?? 'Failed to update card. Please try again.');
  }

    // ─── Save Any QR Code (Type 3) ────────────────────────────
  Future<CollectedCard?> saveQrOther({
    required String name,
    required String qrRawData,
    Map<String, dynamic>? parsedData,
  }) async {
    final res = await ApiClient.instance.post('/collected/qr-other', {
      'name':       name,
      'qrRawData':  qrRawData,
      'parsedData': parsedData ?? {},
    });
    if (res.success) return CollectedCard.fromJson(res.data['card'] as Map<String, dynamic>);
    return null;
  }

  // ─── Photo Upload ─────────────────────────────────────────
  //
  // Card pehle ban chuka hota hai — id guaranteed exist karta hai.
  // Backend Cloudinary pe upload karta hai aur secure_url return karta hai.

  Future<String?> uploadPhoto(String cardId, File photo) async {
    try {
      final token = await ApiClient.instance.getToken();
      if (token == null) return null;

      final uri     = Uri.parse('${ApiClient.baseUrl}/cards/$cardId/photo');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('photo', photo.path));

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      final body     = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return body['photoUrl'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteCard(String id) async {
    final res = await ApiClient.instance.delete('/cards/$id');
    return res.success;
  }

  // ─── Collected Cards ──────────────────────────────────────

  Future<List<CollectedCard>> getCollectedCards() async {
    final res = await ApiClient.instance.get('/collected');
    if (res.success) {
      final list = res.data['collected'] as List<dynamic>;
      return list.map((e) => CollectedCard.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<CollectedCard?> addCollectedCard(Map<String, dynamic> cardData) async {
    final res = await ApiClient.instance.post('/collected', cardData);
    if (res.success) return CollectedCard.fromJson(res.data['card'] as Map<String, dynamic>);
    return null;
  }

  Future<bool> updateCollectedCard(String id, {String? category, String? leadType, String? remarks}) async {
    final body = <String, dynamic>{};
    if (category != null) body['category'] = category;
    if (leadType != null) body['leadType']  = leadType;
    if (remarks  != null) body['remarks']   = remarks;
    final res = await ApiClient.instance.put('/collected/$id', body);
    return res.success;
  }

  Future<bool> deleteCollectedCard(String id) async {
    final res = await ApiClient.instance.delete('/collected/$id');
    return res.success;
  }

  // ─── QR helpers ───────────────────────────────────────────

  String encodeCardToQR(VisitingCard card) {
    return jsonEncode({
      'name': card.name,           'designation': card.designation,
      'company': card.company,     'email1': card.email1,
      'email2': card.email2,       'phone1': card.phone1,
      'phone2': card.phone2,       'website': card.website,
      'address': card.address,     'templateIndex': card.templateIndex,
      'photoUrl': card.photoUrl ?? '',
    });
  }

  Future<CollectedCard?> decodeQRAndSave(String qrData) async {
    try {
      final data = jsonDecode(qrData) as Map<String, dynamic>;
      return await addCollectedCard(data);
    } catch (_) {
      return null;
    }
  }
}

// ─── Result wrapper ───────────────────────────────────────────

class CardResult {
  final bool success;
  final VisitingCard? card;
  final String? message;
  final bool isLimitReached;

  CardResult({
    required this.success,
    this.card,
    this.message,
    this.isLimitReached = false,
  });
}

