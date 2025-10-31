class Member {
  final int? id;
  final String name;
  final String memberId;
  final String? phone;
  final String? photo;
  final String? email;
  final String? createdAt;

  Member({
    this.id,
    required this.name,
    required this.memberId,
    this.phone,
    this.photo,
    this.email,
    this.createdAt,
  });

  Member copy({
    int? id,
    String? name,
    String? memberId,
    String? phone,
    String? photo,
    String? email,
    String? createdAt,
  }) => Member(
    id: id ?? this.id,
    name: name ?? this.name,
    memberId: memberId ?? this.memberId,
    phone: phone ?? this.phone,
    photo: photo ?? this.photo,
    email: email ?? this.email,
    createdAt: createdAt ?? this.createdAt,
  );

  static Member fromMap(Map<String, dynamic> map) => Member(
    id: map['id'] as int?,
    name: map['name'] as String,
    memberId: map['member_id'] as String,
    phone: map['phone'] as String?,
    photo: map['photo'] as String?,
    email: map['email'] as String?,
    createdAt: map['created_at'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'member_id': memberId,
    'phone': phone,
    'photo': photo,
    'email': email,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
  };
}
