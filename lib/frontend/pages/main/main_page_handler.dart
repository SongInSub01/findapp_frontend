import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'package:my_flutter_starter/frontend/common/widgets/inline_feature_panels.dart';

class MainPageHandler {
  MainPageHandler({
    required this.context,
    required this.controller,
    required this.state,
  });

  final BuildContext context;
  final AppController controller;
  final AppState state;

  void openMenu() {
    Navigator.of(context).pushNamed(AppRoutes.sideMenu);
  }

  void openNotifications() {
    showNotificationPanel(context, controller: controller, state: state);
  }

  void trackDevice(String deviceId) {
    controller.openMapForTarget(deviceId);
  }

  void dismissAlert(String deviceId) {
    controller.dismissFalseAlarm(deviceId);
  }

  void openBleEditor({BleDevice? device}) {
    showBleDeviceEditorPanel(
      context,
      controller: controller,
      state: state,
      device: device,
    );
  }

  void openLostItemEditor() {
    showLostItemEditorPanel(context, controller: controller);
  }

  void openRewardEditor({String? itemId}) {
    showRewardEditorPanel(
      context,
      controller: controller,
      state: state,
      initialItemId: itemId,
    );
  }

  void openDiscovery() {
    Navigator.of(context).pushNamed(AppRoutes.discovery);
  }

  void refreshNearbyItems() {
    controller.refreshNearbyItems();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('주변 BLE 탐색 목록을 갱신했습니다.')));
  }

  Future<void> openChatForLostItem(LostItem item) async {
    try {
      final threadId = await controller.openOrCreateChatForItem(item.id);
      if (!context.mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamed(AppRoutes.chatDetail, arguments: threadId);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }
}
