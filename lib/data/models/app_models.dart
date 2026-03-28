/// 탭 이름은 협업 시 바로 알아볼 수 있게 MAIN / MAP / CHAT / SETTING 기준으로 단순화한다.
enum AppTab { main, map, chat, setting }

enum ItemStatus { safe, lost, contact }

enum PhotoAccessStatus { locked, pending, approved }

enum ChatSender { me, other, system }

enum ChatMessageType { text, photoRequest, photoApproved, report }

enum NotificationType { alert, approval, info, report }

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
    required this.mapX,
    required this.mapY,
    this.distance,
    this.reward,
    this.photoAssetPath,
  });

  final String id;
  final String name;
  final String iconKey;
  final ItemStatus status;
  final String location;
  final String lastSeen;
  final String bleCode;
  final double mapX;
  final double mapY;
  final String? distance;
  final int? reward;
  final String? photoAssetPath;

  BleDevice copyWith({
    String? id,
    String? name,
    String? iconKey,
    ItemStatus? status,
    String? location,
    String? lastSeen,
    String? bleCode,
    double? mapX,
    double? mapY,
    String? distance,
    int? reward,
    String? photoAssetPath,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      status: status ?? this.status,
      location: location ?? this.location,
      lastSeen: lastSeen ?? this.lastSeen,
      bleCode: bleCode ?? this.bleCode,
      mapX: mapX ?? this.mapX,
      mapY: mapY ?? this.mapY,
      distance: distance ?? this.distance,
      reward: reward ?? this.reward,
      photoAssetPath: photoAssetPath ?? this.photoAssetPath,
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
  });

  final int distanceMeters;
  final int disconnectMinutes;
  final bool vibrationEnabled;
  final bool soundEnabled;
  final bool autoApprovePhotos;
  final bool keepPhotoPrivateByDefault;

  AlertSettings copyWith({
    int? distanceMeters,
    int? disconnectMinutes,
    bool? vibrationEnabled,
    bool? soundEnabled,
    bool? autoApprovePhotos,
    bool? keepPhotoPrivateByDefault,
  }) {
    return AlertSettings(
      distanceMeters: distanceMeters ?? this.distanceMeters,
      disconnectMinutes: disconnectMinutes ?? this.disconnectMinutes,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoApprovePhotos: autoApprovePhotos ?? this.autoApprovePhotos,
      keepPhotoPrivateByDefault:
          keepPhotoPrivateByDefault ?? this.keepPhotoPrivateByDefault,
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

class AppState {
  const AppState({
    required this.currentTab,
    required this.selectedMapTargetId,
    required this.userProfile,
    required this.myDevices,
    required this.lostItems,
    required this.chatThreads,
    required this.safeZones,
    required this.alertSettings,
    required this.notifications,
    required this.reports,
  });

  final AppTab currentTab;
  final String? selectedMapTargetId;
  final UserProfile userProfile;
  final List<BleDevice> myDevices;
  final List<LostItem> lostItems;
  final List<ChatThread> chatThreads;
  final List<SafeZone> safeZones;
  final AlertSettings alertSettings;
  final List<NotificationItem> notifications;
  final List<ReportRecord> reports;

  factory AppState.empty() {
    return AppState(
      currentTab: AppTab.main,
      selectedMapTargetId: null,
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
      ),
      notifications: const [],
      reports: const [],
    );
  }

  AppState copyWith({
    AppTab? currentTab,
    String? selectedMapTargetId,
    bool clearSelectedMapTarget = false,
    UserProfile? userProfile,
    List<BleDevice>? myDevices,
    List<LostItem>? lostItems,
    List<ChatThread>? chatThreads,
    List<SafeZone>? safeZones,
    AlertSettings? alertSettings,
    List<NotificationItem>? notifications,
    List<ReportRecord>? reports,
  }) {
    return AppState(
      currentTab: currentTab ?? this.currentTab,
      selectedMapTargetId: clearSelectedMapTarget
          ? null
          : selectedMapTargetId ?? this.selectedMapTargetId,
      userProfile: userProfile ?? this.userProfile,
      myDevices: myDevices ?? this.myDevices,
      lostItems: lostItems ?? this.lostItems,
      chatThreads: chatThreads ?? this.chatThreads,
      safeZones: safeZones ?? this.safeZones,
      alertSettings: alertSettings ?? this.alertSettings,
      notifications: notifications ?? this.notifications,
      reports: reports ?? this.reports,
    );
  }
}
