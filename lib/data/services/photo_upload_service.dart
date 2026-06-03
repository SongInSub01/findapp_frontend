import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:my_flutter_starter/core/config/app_config.dart';

class PhotoUploadService {
  static final _picker = ImagePicker();

  /// 갤러리 또는 카메라에서 사진 선택 후 서버에 업로드하고 URL 반환
  static Future<String?> pickAndUpload({
    required ImageSource source,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked == null) return null;

    final file = File(picked.path);
    final url = await _upload(file);
    return url;
  }

  static Future<String> _upload(File file) async {
    final baseUrl = AppConfig.apiBaseUrl;
    if (baseUrl.isEmpty) {
      throw Exception('API URL이 설정되지 않았습니다.');
    }

    final uri = Uri.parse('$baseUrl/api/v1/uploads');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('사진 업로드에 실패했습니다.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final imageUrl = json['imageUrl'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception('업로드 응답에 URL이 없습니다.');
    }

    return imageUrl;
  }
}
