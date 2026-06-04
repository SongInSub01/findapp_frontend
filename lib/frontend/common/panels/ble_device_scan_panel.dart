import 'package:flutter/material.dart';

import 'package:my_flutter_starter/core/ble/ble_tag_service.dart';

/// 주변 BLE 태그를 검색하고 사용자가 등록할 태그 한 개를 선택하게 한다.
Future<BleTagCandidate?> showBleDeviceScanPanel(BuildContext context) {
  return showModalBottomSheet<BleTagCandidate>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _BleDeviceScanPanel(),
  );
}

class _BleDeviceScanPanel extends StatefulWidget {
  const _BleDeviceScanPanel();

  @override
  State<_BleDeviceScanPanel> createState() => _BleDeviceScanPanelState();
}

class _BleDeviceScanPanelState extends State<_BleDeviceScanPanel> {
  final BleTagService _service = BleTagService();
  late Future<List<BleTagCandidate>> _candidates;

  @override
  void initState() {
    super.initState();
    _candidates = _service.scanNearby();
  }

  void _retry() {
    setState(() => _candidates = _service.scanNearby());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '주변 BLE 기기',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: '다시 검색',
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('등록할 태그를 선택하면 BLE 코드가 자동으로 입력됩니다.'),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<BleTagCandidate>>(
                  future: _candidates,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          snapshot.error.toString().replaceFirst(
                            'Exception: ',
                            '',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final candidates = snapshot.data ?? const [];
                    if (candidates.isEmpty) {
                      return const Center(
                        child: Text('주변에서 BLE 기기를 찾지 못했습니다.'),
                      );
                    }
                    return ListView.separated(
                      itemCount: candidates.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final candidate = candidates[index];
                        return ListTile(
                          leading: const Icon(Icons.bluetooth_rounded),
                          title: Text(candidate.displayName),
                          subtitle: Text(
                            '${candidate.remoteId} · ${candidate.rssi} dBm',
                          ),
                          onTap: () => Navigator.of(context).pop(candidate),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
