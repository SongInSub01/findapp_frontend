import 'package:my_flutter_starter/core/storage/session_store.dart';

class FakeSessionStore implements SessionStore {
  String? _loginId;

  @override
  Future<void> clearLoginId() async {
    _loginId = null;
  }

  @override
  Future<String?> readLoginId() async => _loginId;

  @override
  Future<void> saveLoginId(String loginId) async {
    _loginId = loginId;
  }
}
