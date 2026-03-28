import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/frontend_scope.dart';

import 'setting_page_body.dart';
import 'setting_page_handler.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);
    final state = controller.state;
    final handler = SettingPageHandler(
      context: context,
      controller: controller,
      state: state,
    );

    return SettingPageBody(
      state: state,
      handler: handler,
    );
  }
}
