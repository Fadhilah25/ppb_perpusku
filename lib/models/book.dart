class Book {
  final int? id;
  final String title;
  final String author;
  final String? isbn;
  final String category;
  final int stock;
  final String? coverPhoto;
  final String? description;
  final String? createdAt;

  Book({
    this.id,
    required this.title,
    required this.author,
    this.isbn,
    required this.category,
    required this.stock,
    this.coverPhoto,
    this.description,
    this.createdAt,
  });

  Book copy({
    int? id,
    String? title,
    String? author,
    String? isbn,
    String? category,
    int? stock,
    String? coverPhoto,
    String? description,
    String? createdAt,
  }) => Book(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author ?? this.author,
    isbn: isbn ?? this.isbn,
    category: category ?? this.category,
    stock: stock ?? this.stock,
    coverPhoto: coverPhoto ?? this.coverPhoto,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
  );

  static Book fromMap(Map<String, dynamic> map) => Book(
    id: map['id'] as int?,
    title: map['title'] as String,
    author: map['author'] as String,
    isbn: map['isbn'] as String?,
    category: map['category'] as String,
    stock: map['stock'] as int,
    coverPhoto: map['cover_photo'] as String?,
    description: map['description'] as String?,
    createdAt: map['created_at'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'author': author,
    'isbn': isbn,
    'category': category,
    'stock': stock,
    'cover_photo': coverPhoto,
    'description': description,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
  };

  bool get isAvailable => stock > 0;
}
