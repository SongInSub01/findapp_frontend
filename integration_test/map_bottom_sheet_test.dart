import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/find_app.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

import '../test/support/fake_app_repository.dart';
import '../test/support/fake_session_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('지도 bottom sheet는 드래그에 따라 확장과 축소를 반복한다', (
    tester,
  ) async {
    final sessionStore = FakeSessionStore();
    await sessionStore.saveLoginId('tester@example.com');

    final controller = await AppController.create(
      repository: FakeAppRepository(),
      sessionStore: sessionStore,
    );

    await tester.pumpWidget(
      AppScope(controller: controller, child: const FindApp()),
    );
    await tester.pumpAndSettle();

    controller.switchTab(AppTab.map);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    final locateButton = find.byType(FloatingActionButton);
    final initialPosition = tester.getTopLeft(locateButton);

    await tester.drag(find.byType(Scrollable).last, const Offset(0, -260));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final expandedPosition = tester.getTopLeft(locateButton);
    expect(expandedPosition.dy, lessThan(initialPosition.dy));

    await tester.drag(find.byType(Scrollable).last, const Offset(0, 260));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final collapsedPosition = tester.getTopLeft(locateButton);
    expect(collapsedPosition.dy, greaterThan(expandedPosition.dy));
  });
}
