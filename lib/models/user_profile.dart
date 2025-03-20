class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String profilePicture;
  final String memberSince;
  final String subscription;
  final String farmId; // Links to Farm

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profilePicture,
    required this.memberSince,
    required this.subscription,
    required this.farmId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      profilePicture: json['profile_picture'] ?? '',
      memberSince: json['member_since'],
      subscription: json['subscription'] ?? 'Free',
      farmId: json['farm_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'profile_picture': profilePicture,
      'member_since': memberSince,
      'subscription': subscription,
      'farm_id': farmId,
    };
  }
}