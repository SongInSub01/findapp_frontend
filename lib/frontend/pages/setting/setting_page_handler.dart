import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'package:my_flutter_starter/frontend/common/widgets/inline_feature_panels.dart';

class SettingPageHandler {
  SettingPageHandler({
    required this.context,
    required this.controller,
    required this.state,
  });

  final BuildContext context;
  final AppController controller;
  final AppState state;

  void openBleEditor({BleDevice? device}) {
    showBleDeviceEditorPanel(
      context,
      controller: controller,
      state: state,
      device: device,
    );
  }

  Future<void> testBleDevice(BleDevice device) async {
    try {
      await controller.testBleDevice(device.id);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${device.name} BLE 테스트를 전송했습니다.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> updateAlertSettings(AlertSettings settings) async {
    try {
      await controller.updateAlertSettings(settings);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void openSafeZoneEditor({SafeZone? zone}) {
    showSafeZoneEditorPanel(
      context,
      controller: controller,
      zone: zone,
    );
  }

  void openProfileEditor() {
    showProfileEditorPanel(
      context,
      controller: controller,
      profile: state.userProfile,
    );
  }

  void openNotifications() {
    showNotificationPanel(
      context,
      controller: controller,
      state: state,
    );
  }

  void openReports() {
    showReportPanel(context, state: state);
  }

  void openHelp() {
    showHelpPanel(context);
  }

  void openAbout() {
    showAppAboutDialog(context);
  }

  Future<void> pickNumber({
    required String title,
    required List<int> values,
    required int currentValue,
    required ValueChanged<int> onSelected,
    required String suffix,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final value in values)
                      ChoiceChip(
                        label: Text('$value$suffix'),
                        selected: value == currentValue,
                        onSelected: (_) {
                          onSelected(value);
                          Navigator.of(context).pop();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> logout() async {
    await controller.signOut();
    if (!context.mounted) {
      return;
    }
    await Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }
}
