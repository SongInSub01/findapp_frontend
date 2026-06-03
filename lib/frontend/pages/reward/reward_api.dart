import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart'
    as http;

class RewardApi {

  static const String baseUrl =
      String.fromEnvironment(
    'APP_API_BASE_URL',
  );

  /// =========================
  /// 리워드 조회
  /// =========================

  static Future<Map<String, dynamic>>
  getRewardStatus({
    required String email,
  }) async {

    try {

      final url =
          '$baseUrl/api/v1/rewards?email=$email';

      debugPrint(
        '리워드 요청 URL: $url',
      );

      

      final response =
          await http.get(
        Uri.parse(url),
      );

      debugPrint(
        '응답 코드: ${response.statusCode}',
      );

      debugPrint(
        '응답 바디: ${response.body}',
      );

      if (response.statusCode != 200) {

        throw Exception(
          '리워드 조회 실패',
        );
      }

      final decoded =
          jsonDecode(response.body);

      return decoded['rewardStatus'];

    } catch (e) {

      debugPrint(
        '리워드 조회 에러: $e',
      );

      rethrow;
    }
  }

  /// =========================
  /// 퀘스트 수령
  /// =========================

  static Future<Map<String, dynamic>>
  claimQuest({
    required String email,
    required String questCode,
  }) async {

    try {

      final url =
          '$baseUrl/api/v1/rewards/quests/$questCode/claim';

        debugPrint('===== CLAIM URL =====');
        debugPrint(url);
        debugPrint('=====================');

      final response =
          await http.post(
        Uri.parse(url),

        headers: {
          'Content-Type':
              'application/json',
        },

        body: jsonEncode({
          'email': email,
        }),
      );

      debugPrint(
        '퀘스트 수령 응답: ${response.body}',
      );

      if (response.statusCode != 200) {

        throw Exception(
          jsonDecode(
            response.body,
          )['message'],
        );
      }

      final decoded =
          jsonDecode(response.body);

      return decoded['rewardStatus'];

    } catch (e) {

      debugPrint(
        '퀘스트 수령 에러: $e',
      );

      rethrow;
    }
  }

  /// =========================
  /// 상품 구매
  /// =========================

  static Future<Map<String, dynamic>>
  purchaseItem({
    required String email,
    required String itemId,
  }) async {

    try {

      final url =
          '$baseUrl/api/v1/rewards/shop/$itemId/purchase';

      final response =
          await http.post(
        Uri.parse(url),

        headers: {
          'Content-Type':
              'application/json',
        },

        body: jsonEncode({
          'email': email,
        }),
      );

      debugPrint(
        '상품 구매 응답: ${response.body}',
      );

      if (response.statusCode != 200) {

        throw Exception(
          jsonDecode(
            response.body,
          )['message'],
        );
      }

      final decoded =
          jsonDecode(response.body);

      return decoded['rewardStatus'];

    } catch (e) {

      debugPrint(
        '상품 구매 에러: $e',
      );

      rethrow;
    }
  }
}