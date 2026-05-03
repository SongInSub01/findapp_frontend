/// 탭 이름은 협업 시 바로 알아볼 수 있게 MAIN / MAP / CHAT / SETTING 기준으로 단순화한다.
enum AppTab { main, map, chat, setting }

enum ItemStatus { safe, lost, contact }

enum BleSignalStatus { near, far, risk, disconnected, lost, rediscovered }

enum PhotoAccessStatus { locked, pending, approved }

enum ChatSender { me, other, system }

enum ChatMessageType { text, photoRequest, photoApproved, report }

enum NotificationType { alert, approval, info, report }

enum MapThemeMode { dark, light }

enum ListingType { lost, found }

enum ListingWorkflowStatus { open, matched, resolved, archived }

enum MatchStatus { suggested, reviewing, confirmed, dismissed }

enum InquiryCategory { report, support, moderation }

enum InquiryStatus { open, reviewing, resolved, closed }

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.loginId,
    required this.initials,
    required this.photoAssetPath,
    required this.publicName,
  });

  final String id;
  final String name;
  final String email;
  final String loginId;
  final String initials;
  final String photoAssetPath;
  final String publicName;

  factory UserProfile.empty() {
    return const UserProfile(
      id: '',
      name: '',
      email: '',
      loginId: '',
      initials: '',
      photoAssetPath: '',
      publicName: '',
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? loginId,
    String? initials,
    String? photoAssetPath,
    String? publicName,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      loginId: loginId ?? this.loginId,
      initials: initials ?? this.initials,
      photoAssetPath: photoAssetPath ?? this.photoAssetPath,
      publicName: publicName ?? this.publicName,
    );
  }
}

class BleDevice {
  const BleDevice({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.status,
    required this.location,
    required this.lastSeen,
    required this.bleCode,
    required this.lastSignalAt,
    this.bleStatus = BleSignalStatus.near,
    required this.mapX,
    required this.mapY,
    this.distance,
    this.reward,
    this.photoAssetPath,
    this.lastRssi,
    this.lastDetectedLatitude,
    this.lastDetectedLongitude,
    this.lastDetectedAccuracyMeters,
    this.focusedScanUntil,
    this.rediscoveredAt,
  });

  final String id;
  final String name;
  final String iconKey;
  final ItemStatus status;
  final String location;
  final String lastSeen;
  final String bleCode;
  final String lastSignalAt;
  final BleSignalStatus bleStatus;
  final double mapX;
  final double mapY;
  final String? distance;
  final int? reward;
  final String? photoAssetPath;
  final int? lastRssi;
  final double? lastDetectedLatitude;
  final double? lastDetectedLongitude;
  final double? lastDetectedAccuracyMeters;
  final String? focusedScanUntil;
  final String? rediscoveredAt;

  BleDevice copyWith({
    String? id,
    String? name,
    String? iconKey,
    ItemStatus? status,
    String? location,
    String? lastSeen,
    String? bleCode,
    String? lastSignalAt,
    BleSignalStatus? bleStatus,
    double? mapX,
    double? mapY,
    String? distance,
    int? reward,
    String? photoAssetPath,
    int? lastRssi,
    double? lastDetectedLatitude,
    double? lastDetectedLongitude,
    double? lastDetectedAccuracyMeters,
    String? focusedScanUntil,
    String? rediscoveredAt,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      status: status ?? this.status,
      location: location ?? this.location,
      lastSeen: lastSeen ?? this.lastSeen,
      bleCode: bleCode ?? this.bleCode,
      lastSignalAt: lastSignalAt ?? this.lastSignalAt,
      bleStatus: bleStatus ?? this.bleStatus,
      mapX: mapX ?? this.mapX,
      mapY: mapY ?? this.mapY,
      distance: distance ?? this.distance,
      reward: reward ?? this.reward,
      photoAssetPath: photoAssetPath ?? this.photoAssetPath,
      lastRssi: lastRssi ?? this.lastRssi,
      lastDetectedLatitude: lastDetectedLatitude ?? this.lastDetectedLatitude,
      lastDetectedLongitude:
          lastDetectedLongitude ?? this.lastDetectedLongitude,
      lastDetectedAccuracyMeters:
          lastDetectedAccuracyMeters ?? this.lastDetectedAccuracyMeters,
      focusedScanUntil: focusedScanUntil ?? this.focusedScanUntil,
      rediscoveredAt: rediscoveredAt ?? this.rediscoveredAt,
    );
  }
}

class LostItem {
  const LostItem({
    required this.id,
    required this.title,
    required this.location,
    required this.timeLabel,
    required this.reward,
    required this.status,
    required this.photoStatus,
    required this.distance,
    required this.ownerName,
    required this.description,
    required this.sourceDeviceId,
    required this.mapX,
    required this.mapY,
    this.threadId,
    this.photoAssetPath,
  });

  final String id;
  final String title;
  final String location;
  final String timeLabel;
  final int reward;
  final ItemStatus status;
  final PhotoAccessStatus photoStatus;
  final String distance;
  final String ownerName;
  final String description;
  final String? sourceDeviceId;
  final double mapX;
  final double mapY;
  final String? threadId;
  final String? photoAssetPath;

  LostItem copyWith({
    String? id,
    String? title,
    String? location,
    String? timeLabel,
    int? reward,
    ItemStatus? status,
    PhotoAccessStatus? photoStatus,
    String? distance,
    String? ownerName,
    String? description,
    String? sourceDeviceId,
    double? mapX,
    double? mapY,
    String? threadId,
    String? photoAssetPath,
  }) {
    return LostItem(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      timeLabel: timeLabel ?? this.timeLabel,
      reward: reward ?? this.reward,
      status: status ?? this.status,
      photoStatus: photoStatus ?? this.photoStatus,
      distance: distance ?? this.distance,
      ownerName: ownerName ?? this.ownerName,
      description: description ?? this.description,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      mapX: mapX ?? this.mapX,
      mapY: mapY ?? this.mapY,
      threadId: threadId ?? this.threadId,
      photoAssetPath: photoAssetPath ?? this.photoAssetPath,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timeLabel,
    required this.type,
  });

  final String id;
  final String text;
  final ChatSender sender;
  final String timeLabel;
  final ChatMessageType type;
}

class ChatThread {
  const ChatThread({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.itemStatus,
    required this.lastMessage,
    required this.lastTime,
    required this.unread,
    required this.photoStatus,
    required this.otherUser,
    required this.messages,
    this.reward,
  });

  final String id;
  final String itemId;
  final String itemTitle;
  final ItemStatus itemStatus;
  final String lastMessage;
  final String lastTime;
  final int unread;
  final PhotoAccessStatus photoStatus;
  final String otherUser;
  final int? reward;
  final List<ChatMessage> messages;

  ChatThread copyWith({
    String? id,
    String? itemId,
    String? itemTitle,
    ItemStatus? itemStatus,
    String? lastMessage,
    String? lastTime,
    int? unread,
    PhotoAccessStatus? photoStatus,
    String? otherUser,
    int? reward,
    List<ChatMessage>? messages,
  }) {
    return ChatThread(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      itemStatus: itemStatus ?? this.itemStatus,
      lastMessage: lastMessage ?? this.lastMessage,
      lastTime: lastTime ?? this.lastTime,
      unread: unread ?? this.unread,
      photoStatus: photoStatus ?? this.photoStatus,
      otherUser: otherUser ?? this.otherUser,
      reward: reward ?? this.reward,
      messages: messages ?? this.messages,
    );
  }
}

class SafeZone {
  const SafeZone({
    required this.id,
    required this.name,
    required this.address,
    required this.radiusMeters,
  });

  final String id;
  final String name;
  final String address;
  final int radiusMeters;

  SafeZone copyWith({
    String? id,
    String? name,
    String? address,
    int? radiusMeters,
  }) {
    return SafeZone(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      radiusMeters: radiusMeters ?? this.radiusMeters,
    );
  }
}

class AlertSettings {
  const AlertSettings({
    required this.distanceMeters,
    required this.disconnectMinutes,
    required this.vibrationEnabled,
    required this.soundEnabled,
    required this.autoApprovePhotos,
    required this.keepPhotoPrivateByDefault,
    required this.defaultReward,
    MapThemeMode? mapTheme,
  }) : mapTheme = mapTheme ?? MapThemeMode.light;

  final int distanceMeters;
  final int disconnectMinutes;
  final bool vibrationEnabled;
  final bool soundEnabled;
  final bool autoApprovePhotos;
  final bool keepPhotoPrivateByDefault;
  final int defaultReward;
  final MapThemeMode mapTheme;

  AlertSettings copyWith({
    int? distanceMeters,
    int? disconnectMinutes,
    bool? vibrationEnabled,
    bool? soundEnabled,
    bool? autoApprovePhotos,
    bool? keepPhotoPrivateByDefault,
    int? defaultReward,
    MapThemeMode? mapTheme,
  }) {
    return AlertSettings(
      distanceMeters: distanceMeters ?? this.distanceMeters,
      disconnectMinutes: disconnectMinutes ?? this.disconnectMinutes,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoApprovePhotos: autoApprovePhotos ?? this.autoApprovePhotos,
      keepPhotoPrivateByDefault:
          keepPhotoPrivateByDefault ?? this.keepPhotoPrivateByDefault,
      defaultReward: defaultReward ?? this.defaultReward,
      mapTheme: mapTheme ?? this.mapTheme,
    );
  }
}

class CurrentLocation {
  const CurrentLocation({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final String updatedAt;

  CurrentLocation copyWith({
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? updatedAt,
  }) {
    return CurrentLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.type,
    required this.isRead,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final NotificationType type;
  final bool isRead;

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    String? timeLabel,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timeLabel: timeLabel ?? this.timeLabel,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ReportRecord {
  const ReportRecord({
    required this.id,
    required this.targetTitle,
    required this.reason,
    required this.createdAtLabel,
    required this.statusLabel,
  });

  final String id;
  final String targetTitle;
  final String reason;
  final String createdAtLabel;
  final String statusLabel;
}

class ListingSummary {
  const ListingSummary({
    required this.id,
    required this.itemType,
    required this.title,
    required this.category,
    required this.color,
    required this.location,
    required this.happenedAt,
    required this.happenedAtLabel,
    required this.listingStatus,
    required this.description,
    required this.featureNotes,
    required this.contactNote,
    required this.ownerDisplayName,
    required this.matchCount,
    required this.isMine,
    this.imageUrl,
    this.reward,
  });

  final String id;
  final ListingType itemType;
  final String title;
  final String category;
  final String color;
  final String location;
  final String happenedAt;
  final String happenedAtLabel;
  final ListingWorkflowStatus listingStatus;
  final String description;
  final String featureNotes;
  final String contactNote;
  final String ownerDisplayName;
  final String? imageUrl;
  final int? reward;
  final int matchCount;
  final bool isMine;
}

class MatchRecord {
  const MatchRecord({
    required this.id,
    required this.score,
    required this.matchStatus,
    required this.reasonSummary,
    required this.lostItem,
    required this.foundItem,
  });

  final String id;
  final double score;
  final MatchStatus matchStatus;
  final String reasonSummary;
  final ListingSummary lostItem;
  final ListingSummary foundItem;
}

class InquiryRecord {
  const InquiryRecord({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.status,
    required this.createdAt,
    required this.createdAtLabel,
    this.relatedItemType,
    this.relatedItemId,
  });

  final String id;
  final InquiryCategory category;
  final String title;
  final String body;
  final InquiryStatus status;
  final ListingType? relatedItemType;
  final String? relatedItemId;
  final String createdAt;
  final String createdAtLabel;
}

class DashboardSummary {
  const DashboardSummary({
    required this.openLostCount,
    required this.openFoundCount,
    required this.matchedCount,
    required this.unreadNotificationCount,
  });

  final int openLostCount;
  final int openFoundCount;
  final int matchedCount;
  final int unreadNotificationCount;

  factory DashboardSummary.empty() {
    return const DashboardSummary(
      openLostCount: 0,
      openFoundCount: 0,
      matchedCount: 0,
      unreadNotificationCount: 0,
    );
  }
}

class AppState {
  const AppState({
    required this.currentTab,
    required this.selectedMapTargetId,
    required this.currentLocation,
    required this.userProfile,
    required this.myDevices,
    required this.lostItems,
    required this.chatThreads,
    required this.safeZones,
    required this.alertSettings,
    required this.notifications,
    required this.reports,
    required this.dashboardSummary,
    required this.myLostListings,
    required this.myFoundListings,
    required this.recentLostListings,
    required this.recentFoundListings,
    required this.suggestedMatches,
    required this.inquiries,
    required this.availableCategories,
    required this.availableColors,
    required this.searchResults,
  });

  final AppTab currentTab;
  final String? selectedMapTargetId;
  final CurrentLocation? currentLocation;
  final UserProfile userProfile;
  final List<BleDevice> myDevices;
  final List<LostItem> lostItems;
  final List<ChatThread> chatThreads;
  final List<SafeZone> safeZones;
  final AlertSettings alertSettings;
  final List<NotificationItem> notifications;
  final List<ReportRecord> reports;
  final DashboardSummary dashboardSummary;
  final List<ListingSummary> myLostListings;
  final List<ListingSummary> myFoundListings;
  final List<ListingSummary> recentLostListings;
  final List<ListingSummary> recentFoundListings;
  final List<MatchRecord> suggestedMatches;
  final List<InquiryRecord> inquiries;
  final List<String> availableCategories;
  final List<String> availableColors;
  final List<ListingSummary> searchResults;

  factory AppState.empty() {
    return AppState(
      currentTab: AppTab.main,
      selectedMapTargetId: null,
      currentLocation: null,
      userProfile: UserProfile.empty(),
      myDevices: const [],
      lostItems: const [],
      chatThreads: const [],
      safeZones: const [],
      alertSettings: const AlertSettings(
        distanceMeters: 10,
        disconnectMinutes: 5,
        vibrationEnabled: true,
        soundEnabled: true,
        autoApprovePhotos: false,
        keepPhotoPrivateByDefault: true,
        defaultReward: 30000,
        mapTheme: MapThemeMode.light,
      ),
      notifications: const [],
      reports: const [],
      dashboardSummary: DashboardSummary.empty(),
      myLostListings: const [],
      myFoundListings: const [],
      recentLostListings: const [],
      recentFoundListings: const [],
      suggestedMatches: const [],
      inquiries: const [],
      availableCategories: const [],
      availableColors: const [],
      searchResults: const [],
    );
  }

  AppState copyWith({
    AppTab? currentTab,
    String? selectedMapTargetId,
    bool clearSelectedMapTarget = false,
    CurrentLocation? currentLocation,
    bool clearCurrentLocation = false,
    UserProfile? userProfile,
    List<BleDevice>? myDevices,
    List<LostItem>? lostItems,
    List<ChatThread>? chatThreads,
    List<SafeZone>? safeZones,
    AlertSettings? alertSettings,
    List<NotificationItem>? notifications,
    List<ReportRecord>? reports,
    DashboardSummary? dashboardSummary,
    List<ListingSummary>? myLostListings,
    List<ListingSummary>? myFoundListings,
    List<ListingSummary>? recentLostListings,
    List<ListingSummary>? recentFoundListings,
    List<MatchRecord>? suggestedMatches,
    List<InquiryRecord>? inquiries,
    List<String>? availableCategories,
    List<String>? availableColors,
    List<ListingSummary>? searchResults,
  }) {
    return AppState(
      currentTab: currentTab ?? this.currentTab,
      selectedMapTargetId: clearSelectedMapTarget
          ? null
          : selectedMapTargetId ?? this.selectedMapTargetId,
      currentLocation: clearCurrentLocation
          ? null
          : currentLocation ?? this.currentLocation,
      userProfile: userProfile ?? this.userProfile,
      myDevices: myDevices ?? this.myDevices,
      lostItems: lostItems ?? this.lostItems,
      chatThreads: chatThreads ?? this.chatThreads,
      safeZones: safeZones ?? this.safeZones,
      alertSettings: alertSettings ?? this.alertSettings,
      notifications: notifications ?? this.notifications,
      reports: reports ?? this.reports,
      dashboardSummary: dashboardSummary ?? this.dashboardSummary,
      myLostListings: myLostListings ?? this.myLostListings,
      myFoundListings: myFoundListings ?? this.myFoundListings,
      recentLostListings: recentLostListings ?? this.recentLostListings,
      recentFoundListings: recentFoundListings ?? this.recentFoundListings,
      suggestedMatches: suggestedMatches ?? this.suggestedMatches,
      inquiries: inquiries ?? this.inquiries,
      availableCategories: availableCategories ?? this.availableCategories,
      availableColors: availableColors ?? this.availableColors,
      searchResults: searchResults ?? this.searchResults,
    );
  }
}
