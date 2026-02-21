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

  Future<CardResult> createCard(VisitingCard card) async {
    final res = await ApiClient.instance.post('/cards', card.toJson());
    if (res.success) return CardResult(success: true, card: VisitingCard.fromJson(res.data['card'] as Map<String, dynamic>));
    if (res.statusCode == 403) return CardResult(success: false, message: res.message, isLimitReached: true);
    return CardResult(success: false, message: res.message ?? 'Failed to create card');
  }

  Future<CardResult> updateCard(VisitingCard card) async {
    final res = await ApiClient.instance.put('/cards/${card.id}', card.toJson());
    if (res.success) return CardResult(success: true, card: VisitingCard.fromJson(res.data['card'] as Map<String, dynamic>));
    return CardResult(success: false, message: res.message ?? 'Failed to update card');
  }

  Future<CardResult> saveCard(VisitingCard card) async {
    if (card.id.isEmpty) return createCard(card);
    final res = await ApiClient.instance.put('/cards/${card.id}', card.toJson());
    if (res.statusCode == 404) return createCard(card);
    if (res.success) return CardResult(success: true, card: VisitingCard.fromJson(res.data['card'] as Map<String, dynamic>));
    if (res.statusCode == 403) return CardResult(success: false, message: res.message, isLimitReached: true);
    return CardResult(success: false, message: res.message ?? 'Failed to save card');
  }

  Future<bool> deleteCard(String id) async {
    final res = await ApiClient.instance.delete('/cards/$id');
    return res.success;
  }

  // ─── Photo Upload ─────────────────────────────────────────

  /// Upload profile photo for a card. Returns the remote URL on success.
 Future<String?> uploadPhoto(String cardId, File photo) async {
  try {
    final token = await ApiClient.instance.getToken();
    if (token == null) {
      print("❌ Token is null");
      return null;
    }

    final uri = Uri.parse('${ApiClient.baseUrl}/cards/$cardId/photo');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('photo', photo.path));

    print("➡️ Uploading to: $uri");
    print("📁 File path: ${photo.path}");

    final streamed = await request.send().timeout(const Duration(seconds: 30));

    print("⬅️ Status Code: ${streamed.statusCode}");

    final res = await http.Response.fromStream(streamed);

    print("⬅️ Raw Response: ${res.body}");

    final body = jsonDecode(res.body);

    if (res.statusCode == 200 && body['success'] == true) {
      print("✅ Upload success");
      return body['photoUrl'];
    }

    print("❌ Upload failed: $body");
    return null;

  } catch (e, stack) {
    print("🔥 Exception: $e");
    print(stack);
    return null;
  }
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
      'name': card.name, 'designation': card.designation, 'company': card.company,
      'email1': card.email1, 'email2': card.email2,
      'phone1': card.phone1, 'phone2': card.phone2,
      'website': card.website, 'address': card.address,
      'templateIndex': card.templateIndex, 'photoUrl': card.photoUrl ?? '',
    });
  }

  Future<CollectedCard?> decodeQRAndSave(String qrData) async {
    try {
      final json = jsonDecode(qrData) as Map<String, dynamic>;
      return await addCollectedCard(json);
    } catch (_) { return null; }
  }
}

class CardResult {
  final bool success;
  final VisitingCard? card;
  final String? message;
  final bool isLimitReached;
  CardResult({required this.success, this.card, this.message, this.isLimitReached = false});
}