class User {
  final String username;
  final String? avatar;
  final DateTime? joinedAt;
  final bool isOnline;

  User({
    required this.username,
    this.avatar,
    this.joinedAt,
    this.isOnline = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '未知用户',
      avatar: json['avatar'],
      joinedAt: json['joinedAt'] != null 
          ? DateTime.parse(json['joinedAt']) 
          : null,
      isOnline: json['isOnline'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'avatar': avatar,
      'joinedAt': joinedAt?.toIso8601String(),
      'isOnline': isOnline,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          username == other.username;

  @override
  int get hashCode => username.hashCode;
}