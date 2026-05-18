class RewardQuest {
  final String code;
  final String title;
  final int rewardMoney;
  final int rewardPoints;
  final int progressCurrent;
  final int progressTarget;
  final String progressLabel;
  final bool completed;
  final bool claimed;
  final String iconKey;

  RewardQuest({
    required this.code,
    required this.title,
    required this.rewardMoney,
    required this.rewardPoints,
    required this.progressCurrent,
    required this.progressTarget,
    required this.progressLabel,
    required this.completed,
    required this.claimed,
    required this.iconKey,
  });

  factory RewardQuest.fromJson(
    Map<String, dynamic> json,
  ) {
    return RewardQuest(
      code: json['code'],
      title: json['title'],
      rewardMoney: json['rewardMoney'],
      rewardPoints: json['rewardPoints'],
      progressCurrent: json['progressCurrent'],
      progressTarget: json['progressTarget'],
      progressLabel: json['progressLabel'],
      completed: json['completed'],
      claimed: json['claimed'],
      iconKey: json['iconKey'],
    );
  }
}

class RewardShopItem {
  final String id;
  final String title;
  final String description;
  final int pricePoints;
  final String iconKey;
  final bool purchased;

  RewardShopItem({
    required this.id,
    required this.title,
    required this.description,
    required this.pricePoints,
    required this.iconKey,
    required this.purchased,
  });

  factory RewardShopItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return RewardShopItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pricePoints: json['pricePoints'],
      iconKey: json['iconKey'],
      purchased: json['purchased'],
    );
  }
}

class RewardBenefit {
  final String tier;
  final String title;
  final String description;
  final int requiredPoints;
  final bool isCurrent;

  RewardBenefit({
    required this.tier,
    required this.title,
    required this.description,
    required this.requiredPoints,
    required this.isCurrent,
  });

  factory RewardBenefit.fromJson(
    Map<String, dynamic> json,
  ) {
    return RewardBenefit(
      tier: json['tier'],
      title: json['title'],
      description: json['description'],
      requiredPoints: json['requiredPoints'],
      isCurrent: json['isCurrent'],
    );
  }
}

class RewardStatus {
  final int currentPoints;
  final int lifetimePoints;
  final int nextGoalPoints;
  final double progress;
  final int streakDays;

  final List<RewardQuest> quests;
  final List<RewardShopItem> shopItems;
  final List<RewardBenefit> benefits;

  RewardStatus({
    required this.currentPoints,
    required this.lifetimePoints,
    required this.nextGoalPoints,
    required this.progress,
    required this.streakDays,
    required this.quests,
    required this.shopItems,
    required this.benefits,
  });

  factory RewardStatus.fromJson(
    Map<String, dynamic> json,
  ) {
    return RewardStatus(
      currentPoints: json['currentPoints'],
      lifetimePoints: json['lifetimePoints'],
      nextGoalPoints: json['nextGoalPoints'],
      progress:
          (json['progress'] as num)
              .toDouble(),
      streakDays: json['streakDays'],

      quests:
          (json['quests'] as List)
              .map(
                (e) =>
                    RewardQuest.fromJson(e),
              )
              .toList(),

      shopItems:
          (json['shopItems'] as List)
              .map(
                (e) =>
                    RewardShopItem.fromJson(
                      e,
                    ),
              )
              .toList(),

      benefits:
          (json['benefits'] as List)
              .map(
                (e) =>
                    RewardBenefit.fromJson(
                      e,
                    ),
              )
              .toList(),
    );
  }
}