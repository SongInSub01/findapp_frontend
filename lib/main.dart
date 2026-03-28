import 'package:flutter/material.dart';

import 'app/state/app_controller.dart';
import 'frontend/find_app.dart';
import 'frontend/frontend_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await AppController.create();
  await controller.bootstrap();
  runApp(
    AppScope(
      controller: controller,
      child: const FindApp(),
    ),
  );
}
