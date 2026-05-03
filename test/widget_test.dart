import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/find_app.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

import 'support/fake_app_repository.dart';
import 'support/fake_session_store.dart';

void main() {
  const loginId = 'tester@example.com';
  const password = 'password123';

  Future<void> tapNavDestination(WidgetTester tester, int index) async {
    final navRect = tester.getRect(find.byType(NavigationBar));
    final step = navRect.width / 4;
    await tester.tapAt(
      Offset(navRect.left + step * (index + 0.5), navRect.center.dy),
    );
  }

  Future<AppController> buildController() {
    return AppController.create(
      repository: FakeAppRepository(),
      sessionStore: FakeSessionStore(),
    );
  }

  testWidgets('찾아줘 로그인 페이지가 첫 화면으로 렌더링된다', (tester) async {
    final controller = await buildController();
    await tester.pumpWidget(
      AppScope(controller: controller, child: const FindApp()),
    );

    await tester.pumpAndSettle();

    expect(find.text('찾아줘'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
    expect(find.text('로그인하고 시작하기'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
    expect(find.text('회원가입 없이 둘러보기'), findsNothing);
  });

  testWidgets('로그인하면 환영 화면으로 이동한다', (tester) async {
    final controller = await buildController();
    await tester.pumpWidget(
      AppScope(controller: controller, child: const FindApp()),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), loginId);
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.ensureVisible(find.text('로그인하고 시작하기'));
    await tester.tap(find.text('로그인하고 시작하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('테스트유저님, 안녕하세요'), findsOneWidget);
    expect(find.text('찾아줘 시작하기'), findsOneWidget);
  });

  testWidgets('환영 화면에서 찾아줘 시작하기를 누르면 MAIN 페이지로 이동한다', (tester) async {
    final controller = await buildController();
    await tester.pumpWidget(
      AppScope(controller: controller, child: const FindApp()),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), loginId);
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.ensureVisible(find.text('로그인하고 시작하기'));
    await tester.tap(find.text('로그인하고 시작하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('찾아줘 시작하기'));
    await tester.tap(find.text('찾아줘 시작하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('지도'), findsOneWidget);
    expect(find.text('채팅'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
  });

  testWidgets('쉘의 탭 버튼이 모두 동작하고 지도 시트가 표시된다', (tester) async {
    final controller = await buildController();
    await tester.pumpWidget(
      AppScope(controller: controller, child: const FindApp()),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), loginId);
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.ensureVisible(find.text('로그인하고 시작하기'));
    await tester.tap(find.text('로그인하고 시작하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('찾아줘 시작하기'));
    await tester.tap(find.text('찾아줘 시작하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await tapNavDestination(tester, 1);
    await tester.pumpAndSettle();
    expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    expect(find.text('주변 분실물 0건'), findsOneWidget);

    final dragHandle = find.byKey(const Key('map-sheet-drag-handle'));
    expect(dragHandle, findsOneWidget);
    final handleTopBefore = tester.getTopLeft(dragHandle).dy;
    await tester.drag(dragHandle, const Offset(0, -220));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    final handleTopAfter = tester.getTopLeft(dragHandle).dy;
    expect(handleTopAfter, lessThan(handleTopBefore));

    await tapNavDestination(tester, 2);
    await tester.pumpAndSettle();
    expect(find.text('진행 중인 채팅이 없습니다'), findsOneWidget);

    controller.switchTab(AppTab.setting);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('로그아웃'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('로그아웃'), findsOneWidget);

    await tapNavDestination(tester, 0);
    await tester.pumpAndSettle();
    expect(find.text('등록된 기기'), findsOneWidget);
    expect(find.text('주변 분실물 리스트'), findsOneWidget);
  });
}
