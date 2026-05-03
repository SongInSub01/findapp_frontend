import 'package:my_flutter_starter/data/models/app_models.dart';

abstract final class AppStateJsonMapper {
  static AppState fromBootstrapJson(Map<String, dynamic> json) {
    return AppState(
      currentTab: AppTab.main,
      selectedMapTargetId: null,
      currentLocation: _currentLocationFromJson(
        json['currentLocation'] as Map<String, dynamic>?,
      ),
      userProfile: _userProfileFromJson(
        json['userProfile'] as Map<String, dynamic>,
      ),
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
      alertSettings: _alertSettingsFromJson(
        json['alertSettings'] as Map<String, dynamic>,
      ),
      notifications: ((json['notifications'] as List<dynamic>?) ?? const [])
          .map((item) => _notificationFromJson(item as Map<String, dynamic>))
          .toList(),
      reports: ((json['reports'] as List<dynamic>?) ?? const [])
          .map((item) => _reportFromJson(item as Map<String, dynamic>))
          .toList(),
      dashboardSummary: _dashboardSummaryFromJson(
        json['dashboardSummary'] as Map<String, dynamic>?,
      ),
      myLostListings: ((json['myLostItems'] as List<dynamic>?) ?? const [])
          .map((item) => _listingSummaryFromJson(item as Map<String, dynamic>))
          .toList(),
      myFoundListings: ((json['myFoundItems'] as List<dynamic>?) ?? const [])
          .map((item) => _listingSummaryFromJson(item as Map<String, dynamic>))
          .toList(),
      recentLostListings:
          ((json['recentLostItems'] as List<dynamic>?) ?? const [])
              .map(
                (item) => _listingSummaryFromJson(item as Map<String, dynamic>),
              )
              .toList(),
      recentFoundListings:
          ((json['recentFoundItems'] as List<dynamic>?) ?? const [])
              .map(
                (item) => _listingSummaryFromJson(item as Map<String, dynamic>),
              )
              .toList(),
      suggestedMatches:
          ((json['suggestedMatches'] as List<dynamic>?) ?? const [])
              .map((item) => _matchFromJson(item as Map<String, dynamic>))
              .toList(),
      inquiries: ((json['inquiries'] as List<dynamic>?) ?? const [])
          .map((item) => _inquiryFromJson(item as Map<String, dynamic>))
          .toList(),
      availableCategories:
          ((json['availableCategories'] as List<dynamic>?) ?? const [])
              .map((item) => item.toString())
              .toList(),
      availableColors: ((json['availableColors'] as List<dynamic>?) ?? const [])
          .map((item) => item.toString())
          .toList(),
      searchResults: const [],
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
      lastSignalAt: json['lastSignalAt'] as String? ?? '',
      bleStatus: _bleSignalStatusFromJson(json['bleStatus'] as String?),
      mapX: _toDouble(json['mapX']),
      mapY: _toDouble(json['mapY']),
      distance: json['distance'] as String?,
      reward: _toInt(json['reward']),
      photoAssetPath: json['photoAssetPath'] as String?,
      lastRssi: _toInt(json['lastRssi']),
      lastDetectedLatitude: json['lastDetectedLatitude'] == null
          ? null
          : _toDouble(json['lastDetectedLatitude']),
      lastDetectedLongitude: json['lastDetectedLongitude'] == null
          ? null
          : _toDouble(json['lastDetectedLongitude']),
      lastDetectedAccuracyMeters: json['lastDetectedAccuracyMeters'] == null
          ? null
          : _toDouble(json['lastDetectedAccuracyMeters']),
      focusedScanUntil: json['focusedScanUntil'] as String?,
      rediscoveredAt: json['rediscoveredAt'] as String?,
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
      sourceDeviceId: json['sourceDeviceId'] as String?,
      mapX: _toDouble(json['mapX']),
      mapY: _toDouble(json['mapY']),
      threadId: json['threadId'] as String?,
      photoAssetPath:
          json['photoAssetPath'] as String? ?? json['imageUrl'] as String?,
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
    final mapThemeValue =
        json['mapTheme'] as String? ?? json['map_theme'] as String?;
    return AlertSettings(
      distanceMeters: _toInt(json['distanceMeters']) ?? 10,
      disconnectMinutes: _toInt(json['disconnectMinutes']) ?? 5,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      autoApprovePhotos: json['autoApprovePhotos'] as bool? ?? false,
      keepPhotoPrivateByDefault:
          json['keepPhotoPrivateByDefault'] as bool? ?? true,
      defaultReward: _toInt(json['defaultReward']) ?? 30000,
      mapTheme: _mapThemeFromJson(mapThemeValue),
    );
  }

  static CurrentLocation? _currentLocationFromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return CurrentLocation(
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      accuracyMeters: json['accuracyMeters'] == null
          ? null
          : _toDouble(json['accuracyMeters']),
      updatedAt: json['updatedAt'] as String? ?? '',
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

  static DashboardSummary _dashboardSummaryFromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return DashboardSummary.empty();
    }
    return DashboardSummary(
      openLostCount: _toInt(json['openLostCount']) ?? 0,
      openFoundCount: _toInt(json['openFoundCount']) ?? 0,
      matchedCount: _toInt(json['matchedCount']) ?? 0,
      unreadNotificationCount: _toInt(json['unreadNotificationCount']) ?? 0,
    );
  }

  static ListingSummary _listingSummaryFromJson(Map<String, dynamic> json) {
    return ListingSummary(
      id: json['id'] as String? ?? '',
      itemType: _listingTypeFromJson(json['itemType'] as String?),
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      color: json['color'] as String? ?? '',
      location: json['location'] as String? ?? '',
      happenedAt: json['happenedAt'] as String? ?? '',
      happenedAtLabel: json['happenedAtLabel'] as String? ?? '',
      listingStatus: _listingWorkflowStatusFromJson(
        json['listingStatus'] as String?,
      ),
      description: json['description'] as String? ?? '',
      featureNotes: json['featureNotes'] as String? ?? '',
      contactNote: json['contactNote'] as String? ?? '',
      ownerDisplayName: json['ownerDisplayName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      reward: _toInt(json['reward']),
      matchCount: _toInt(json['matchCount']) ?? 0,
      isMine: json['isMine'] as bool? ?? false,
    );
  }

  static MatchRecord _matchFromJson(Map<String, dynamic> json) {
    return MatchRecord(
      id: json['id'] as String? ?? '',
      score: _toDouble(json['score']),
      matchStatus: _matchStatusFromJson(json['matchStatus'] as String?),
      reasonSummary: json['reasonSummary'] as String? ?? '',
      lostItem: _listingSummaryFromJson(
        (json['lostItem'] as Map<String, dynamic>?) ?? const {},
      ),
      foundItem: _listingSummaryFromJson(
        (json['foundItem'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  static InquiryRecord _inquiryFromJson(Map<String, dynamic> json) {
    return InquiryRecord(
      id: json['id'] as String? ?? '',
      category: _inquiryCategoryFromJson(json['category'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      status: _inquiryStatusFromJson(json['status'] as String?),
      relatedItemType: json['relatedItemType'] == null
          ? null
          : _listingTypeFromJson(json['relatedItemType'] as String?),
      relatedItemId: json['relatedItemId'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      createdAtLabel: json['createdAtLabel'] as String? ?? '',
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

  static BleSignalStatus _bleSignalStatusFromJson(String? value) {
    switch (value) {
      case 'far':
        return BleSignalStatus.far;
      case 'risk':
        return BleSignalStatus.risk;
      case 'disconnected':
        return BleSignalStatus.disconnected;
      case 'lost':
        return BleSignalStatus.lost;
      case 'rediscovered':
        return BleSignalStatus.rediscovered;
      case 'near':
      default:
        return BleSignalStatus.near;
    }
  }

  static ListingType _listingTypeFromJson(String? value) {
    switch (value) {
      case 'found':
        return ListingType.found;
      case 'lost':
      default:
        return ListingType.lost;
    }
  }

  static ListingWorkflowStatus _listingWorkflowStatusFromJson(String? value) {
    switch (value) {
      case 'matched':
        return ListingWorkflowStatus.matched;
      case 'resolved':
        return ListingWorkflowStatus.resolved;
      case 'archived':
        return ListingWorkflowStatus.archived;
      case 'open':
      default:
        return ListingWorkflowStatus.open;
    }
  }

  static MatchStatus _matchStatusFromJson(String? value) {
    switch (value) {
      case 'reviewing':
        return MatchStatus.reviewing;
      case 'confirmed':
        return MatchStatus.confirmed;
      case 'dismissed':
        return MatchStatus.dismissed;
      case 'suggested':
      default:
        return MatchStatus.suggested;
    }
  }

  static InquiryCategory _inquiryCategoryFromJson(String? value) {
    switch (value) {
      case 'report':
        return InquiryCategory.report;
      case 'moderation':
        return InquiryCategory.moderation;
      case 'support':
      default:
        return InquiryCategory.support;
    }
  }

  static InquiryStatus _inquiryStatusFromJson(String? value) {
    switch (value) {
      case 'reviewing':
        return InquiryStatus.reviewing;
      case 'resolved':
        return InquiryStatus.resolved;
      case 'closed':
        return InquiryStatus.closed;
      case 'open':
      default:
        return InquiryStatus.open;
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

  static MapThemeMode _mapThemeFromJson(String? value) {
    switch (value) {
      case 'light':
        return MapThemeMode.light;
      case 'dark':
      default:
        return MapThemeMode.dark;
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
