import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/repositories/api_app_repository.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';
import 'package:my_flutter_starter/frontend/find_app.dart';
import 'package:my_flutter_starter/frontend/pages/map/map_kakao_bridge.dart';

import '../test/support/fake_session_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const baseUrl = String.fromEnvironment('LIVE_API_BASE_URL');
  const loginId = String.fromEnvironment('LIVE_ACTION_LOGIN_ID');
  const password = String.fromEnvironment('LIVE_ACTION_PASSWORD');

  Future<void> tapNavDestination(WidgetTester tester, int index) async {
    const icons = [
      Icons.home_outlined,
      Icons.map_outlined,
      Icons.chat_bubble_outline_rounded,
      Icons.settings_outlined,
    ];
    final iconFinder = find.byIcon(icons[index]).first;
    if (iconFinder.evaluate().isNotEmpty) {
      await tester.tap(iconFinder);
      return;
    }

    final scaffold = find.byType(Scaffold).last;
    final scaffoldSize = tester.getSize(scaffold);
    final step = scaffoldSize.width / 4;
    await tester.tapAt(Offset(step * (index + 0.5), scaffoldSize.height - 28));
  }

  testWidgets('운영 DB 로그인 후 웰컴과 메인 화면까지 진입한다', (tester) async {
    if (baseUrl.isEmpty || loginId.isEmpty || password.isEmpty) {
      return;
    }

    final repository = ApiAppRepository(baseUrl: baseUrl);
    final controller = AppController(
      initialState: repository.loadInitialState(),
      repository: repository,
      sessionStore: FakeSessionStore(),
    );

    await tester.pumpWidget(
      AppScope(controller: controller, child: const FindApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('로그인'), findsOneWidget);
    expect(find.text('로그인하고 시작하기'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), loginId);
    await tester.enterText(find.byType(TextField).at(1), password);

    await tester.ensureVisible(find.text('로그인하고 시작하기'));
    await tester.tap(find.text('로그인하고 시작하기'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.text('찾아줘 시작하기'), findsWidgets);
    final welcomeStartButton = find.widgetWithText(FilledButton, '찾아줘 시작하기');
    await tester.ensureVisible(welcomeStartButton.first);
    await tester.tap(welcomeStartButton.first);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.text('등록된 기기'), findsOneWidget);
    expect(find.text('주변 분실물 리스트'), findsOneWidget);

    await tapNavDestination(tester, 1);
    await tester.pumpAndSettle(const Duration(seconds: 10));
    expect(find.byType(KakaoMap), findsOneWidget);

    await tapNavDestination(tester, 2);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tapNavDestination(tester, 3);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.scrollUntilVisible(
      find.text('로그아웃'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('로그아웃'), findsOneWidget);

    await tapNavDestination(tester, 0);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('등록된 기기'), findsOneWidget);
  });
}
