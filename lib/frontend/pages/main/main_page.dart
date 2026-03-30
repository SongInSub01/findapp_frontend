import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/frontend_scope.dart';

import 'main_page_body.dart';
import 'main_page_handler.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);
    final state = controller.state;
    final handler = MainPageHandler(
      context: context,
      controller: controller,
      state: state,
    );
    return MainPageBody(
      state: state,
      handler: handler,
    );
  }
}
