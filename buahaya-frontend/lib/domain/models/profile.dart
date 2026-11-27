class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.notificationsEnabled = true,
    this.shoppingListCount = 0,
    this.freshCheckCount = 0,
    this.partnerCount = 0,
  });

  final String id;
  final String fullName;
  final String username;
  final String email;
  final String? avatarUrl;
  final bool notificationsEnabled;
  final int shoppingListCount;
  final int freshCheckCount;
  final int partnerCount;

  String get firstName => fullName.trim().split(' ').first;

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? email,
    String? avatarUrl,
    bool? notificationsEnabled,
    int? shoppingListCount,
    int? freshCheckCount,
    int? partnerCount,
  }) =>
      UserProfile(
        id: id,
        fullName: fullName ?? this.fullName,
        username: username ?? this.username,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        shoppingListCount: shoppingListCount ?? this.shoppingListCount,
        freshCheckCount: freshCheckCount ?? this.freshCheckCount,
        partnerCount: partnerCount ?? this.partnerCount,
      );
}
