import 'package:my_flutter_starter/data/models/app_models.dart';

abstract final class AppStateJsonMapper {
  static AppState fromBootstrapJson(Map<String, dynamic> json) {
    return AppState(
      currentTab: AppTab.main,
      selectedMapTargetId: null,
      userProfile: _userProfileFromJson(json['userProfile'] as Map<String, dynamic>),
      myDevices: ((json['myDevices'] as List<dynamic>?) ?? const [])
          .map((item) => _bleDeviceFromJson(item as Map<String, dynamic>))
          .toList(),
      lostItems: ((json['lostItems'] as List<dynamic>?) ?? const [])
          .map((item) => _lostItemFromJson(item as Map<String, dynamic>))
          .toList(),
      chatThreads: ((json['chatThreads'] as List<dynamic>?) ?? const [])
          .map((item) => _chatThreadFromJson(item as Map<String, dynamic>))
          .toList(),
      safeZones: ((json['safeZones'] as List<dynamic>?) ?? const [])
          .map((item) => _safeZoneFromJson(item as Map<String, dynamic>))
          .toList(),
      alertSettings: _alertSettingsFromJson(json['alertSettings'] as Map<String, dynamic>),
      notifications: ((json['notifications'] as List<dynamic>?) ?? const [])
          .map((item) => _notificationFromJson(item as Map<String, dynamic>))
          .toList(),
      reports: ((json['reports'] as List<dynamic>?) ?? const [])
          .map((item) => _reportFromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static UserProfile _userProfileFromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      loginId: json['loginId'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      photoAssetPath: json['photoAssetPath'] as String? ?? '',
      publicName: json['publicName'] as String? ?? '',
    );
  }

  static BleDevice _bleDeviceFromJson(Map<String, dynamic> json) {
    return BleDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      iconKey: json['iconKey'] as String? ?? 'item',
      status: _itemStatusFromJson(json['status'] as String?),
      location: json['location'] as String? ?? '',
      lastSeen: json['lastSeen'] as String? ?? '',
      bleCode: json['bleCode'] as String? ?? '',
      mapX: _toDouble(json['mapX']),
      mapY: _toDouble(json['mapY']),
      distance: json['distance'] as String?,
      reward: _toInt(json['reward']),
      photoAssetPath: json['photoAssetPath'] as String?,
    );
  }

  static LostItem _lostItemFromJson(Map<String, dynamic> json) {
    return LostItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      timeLabel: json['timeLabel'] as String? ?? '',
      reward: _toInt(json['reward']) ?? 0,
      status: _itemStatusFromJson(json['status'] as String?),
      photoStatus: _photoStatusFromJson(json['photoStatus'] as String?),
      distance: json['distance'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mapX: _toDouble(json['mapX']),
      mapY: _toDouble(json['mapY']),
      threadId: json['threadId'] as String?,
      photoAssetPath: json['photoAssetPath'] as String?,
    );
  }

  static ChatThread _chatThreadFromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id'] as String? ?? '',
      itemId: json['itemId'] as String? ?? '',
      itemTitle: json['itemTitle'] as String? ?? '',
      itemStatus: _itemStatusFromJson(json['itemStatus'] as String?),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastTime: json['lastTime'] as String? ?? '',
      unread: _toInt(json['unread']) ?? 0,
      photoStatus: _photoStatusFromJson(json['photoStatus'] as String?),
      otherUser: json['otherUser'] as String? ?? '',
      reward: _toInt(json['reward']),
      messages: ((json['messages'] as List<dynamic>?) ?? const [])
          .map((item) => _chatMessageFromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static ChatMessage _chatMessageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      sender: _chatSenderFromJson(json['sender'] as String?),
      timeLabel: json['timeLabel'] as String? ?? '',
      type: _chatMessageTypeFromJson(json['type'] as String?),
    );
  }

  static SafeZone _safeZoneFromJson(Map<String, dynamic> json) {
    return SafeZone(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      radiusMeters: _toInt(json['radiusMeters']) ?? 0,
    );
  }

  static AlertSettings _alertSettingsFromJson(Map<String, dynamic> json) {
    return AlertSettings(
      distanceMeters: _toInt(json['distanceMeters']) ?? 10,
      disconnectMinutes: _toInt(json['disconnectMinutes']) ?? 5,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      autoApprovePhotos: json['autoApprovePhotos'] as bool? ?? false,
      keepPhotoPrivateByDefault: json['keepPhotoPrivateByDefault'] as bool? ?? true,
    );
  }

  static NotificationItem _notificationFromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      timeLabel: json['timeLabel'] as String? ?? '',
      type: _notificationTypeFromJson(json['type'] as String?),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  static ReportRecord _reportFromJson(Map<String, dynamic> json) {
    return ReportRecord(
      id: json['id'] as String? ?? '',
      targetTitle: json['targetTitle'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      createdAtLabel: json['createdAtLabel'] as String? ?? '',
      statusLabel: json['statusLabel'] as String? ?? '',
    );
  }

  static ItemStatus _itemStatusFromJson(String? value) {
    switch (value) {
      case 'safe':
        return ItemStatus.safe;
      case 'contact':
        return ItemStatus.contact;
      case 'lost':
      default:
        return ItemStatus.lost;
    }
  }

  static PhotoAccessStatus _photoStatusFromJson(String? value) {
    switch (value) {
      case 'approved':
        return PhotoAccessStatus.approved;
      case 'pending':
        return PhotoAccessStatus.pending;
      case 'locked':
      default:
        return PhotoAccessStatus.locked;
    }
  }

  static ChatSender _chatSenderFromJson(String? value) {
    switch (value) {
      case 'other':
        return ChatSender.other;
      case 'system':
        return ChatSender.system;
      case 'me':
      default:
        return ChatSender.me;
    }
  }

  static ChatMessageType _chatMessageTypeFromJson(String? value) {
    switch (value) {
      case 'photoRequest':
        return ChatMessageType.photoRequest;
      case 'photoApproved':
        return ChatMessageType.photoApproved;
      case 'report':
        return ChatMessageType.report;
      case 'text':
      default:
        return ChatMessageType.text;
    }
  }

  static NotificationType _notificationTypeFromJson(String? value) {
    switch (value) {
      case 'alert':
        return NotificationType.alert;
      case 'approval':
        return NotificationType.approval;
      case 'report':
        return NotificationType.report;
      case 'info':
      default:
        return NotificationType.info;
    }
  }

  static double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static int? _toInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
