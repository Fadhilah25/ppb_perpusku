class Member {
  final int? id;
  final String name;
  final String memberId;
  final String phone;
  final String? photo;
  final DateTime registrationDate;

  Member({
    this.id,
    required this.name,
    required this.memberId,
    required this.phone,
    this.photo,
    DateTime? registrationDate,
  }) : registrationDate = registrationDate ?? DateTime.now();

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'member_id': memberId,
      'phone': phone,
      'photo': photo,
      'registration_date': registrationDate.toIso8601String(),
    };
  }

  // Create from Map
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as int?,
      name: map['name'] as String,
      memberId: map['member_id'] as String,
      phone: map['phone'] as String,
      photo: map['photo'] as String?,
      registrationDate: DateTime.parse(map['registration_date'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'member_id': memberId,
      'phone': phone,
      'photo': photo,
      'registration_date': registrationDate.toIso8601String(),
    };
  }

  // Create from JSON
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as int?,
      name: json['name'] as String,
      memberId: json['member_id'] as String,
      phone: json['phone'] as String,
      photo: json['photo'] as String?,
      registrationDate: DateTime.parse(json['registration_date'] as String),
    );
  }

  // Copy with method for updates
  Member copyWith({
    int? id,
    String? name,
    String? memberId,
    String? phone,
    String? photo,
    DateTime? registrationDate,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      memberId: memberId ?? this.memberId,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }
}
