class UserProfile {
  final String name;
  final String phone;
  final String email;
  final String about;
  final String? imageUrl;

  UserProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.about,
    this.imageUrl,
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? about,
    String? imageUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      about: about ?? this.about,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'about': about,
      'imageUrl': imageUrl,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      about: json['about'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}
