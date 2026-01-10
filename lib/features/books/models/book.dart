class Book {
  final int? id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final int stock;
  final String? coverPhoto;
  final DateTime createdAt;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.stock,
    this.coverPhoto,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Check if book is available for borrowing
  bool get isAvailable => stock > 0;

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'category': category,
      'stock': stock,
      'cover_photo': coverPhoto,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      title: map['title'] as String,
      author: map['author'] as String,
      isbn: map['isbn'] as String,
      category: map['category'] as String,
      stock: map['stock'] as int,
      coverPhoto: map['cover_photo'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'category': category,
      'stock': stock,
      'cover_photo': coverPhoto,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int?,
      title: json['title'] as String,
      author: json['author'] as String,
      isbn: json['isbn'] as String,
      category: json['category'] as String,
      stock: json['stock'] as int,
      coverPhoto: json['cover_photo'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Copy with method for updates
  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? isbn,
    String? category,
    int? stock,
    String? coverPhoto,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
