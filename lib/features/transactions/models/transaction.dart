class Transaction {
  final int? id;
  final int bookId;
  final int memberId;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final double fine;
  final String status; // 'borrowed', 'returned', 'overdue'

  // Related objects (not stored in DB, loaded separately)
  String? bookTitle;
  String? memberName;

  Transaction({
    this.id,
    required this.bookId,
    required this.memberId,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    this.fine = 0.0,
    required this.status,
    this.bookTitle,
    this.memberName,
  });

  // Calculate fine based on days late (Rp 1000 per day)
  static const double finePerDay = 1000.0;

  double calculateFine() {
    if (returnDate == null) {
      // Still borrowed, check if overdue
      final now = DateTime.now();
      if (now.isAfter(dueDate)) {
        final daysLate = now.difference(dueDate).inDays;
        return daysLate * finePerDay;
      }
      return 0.0;
    } else {
      // Returned, calculate based on actual return date
      if (returnDate!.isAfter(dueDate)) {
        final daysLate = returnDate!.difference(dueDate).inDays;
        return daysLate * finePerDay;
      }
      return 0.0;
    }
  }

  int get daysLate {
    final referenceDate = returnDate ?? DateTime.now();
    if (referenceDate.isAfter(dueDate)) {
      return referenceDate.difference(dueDate).inDays;
    }
    return 0;
  }

  bool get isOverdue {
    if (status == 'returned') return false;
    return DateTime.now().isAfter(dueDate);
  }

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'member_id': memberId,
      'borrow_date': borrowDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'fine': fine,
      'status': status,
    };
  }

  // Create from Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      bookId: map['book_id'] as int,
      memberId: map['member_id'] as int,
      borrowDate: DateTime.parse(map['borrow_date'] as String),
      dueDate: DateTime.parse(map['due_date'] as String),
      returnDate: map['return_date'] != null
          ? DateTime.parse(map['return_date'] as String)
          : null,
      fine: (map['fine'] as num).toDouble(),
      status: map['status'] as String,
      bookTitle: map['book_title'] as String?,
      memberName: map['member_name'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'member_id': memberId,
      'borrow_date': borrowDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'fine': fine,
      'status': status,
    };
  }

  // Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      bookId: json['book_id'] as int,
      memberId: json['member_id'] as int,
      borrowDate: DateTime.parse(json['borrow_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'] as String)
          : null,
      fine: (json['fine'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  // Copy with method for updates
  Transaction copyWith({
    int? id,
    int? bookId,
    int? memberId,
    DateTime? borrowDate,
    DateTime? dueDate,
    DateTime? returnDate,
    double? fine,
    String? status,
    String? bookTitle,
    String? memberName,
  }) {
    return Transaction(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      memberId: memberId ?? this.memberId,
      borrowDate: borrowDate ?? this.borrowDate,
      dueDate: dueDate ?? this.dueDate,
      returnDate: returnDate ?? this.returnDate,
      fine: fine ?? this.fine,
      status: status ?? this.status,
      bookTitle: bookTitle ?? this.bookTitle,
      memberName: memberName ?? this.memberName,
    );
  }
}
