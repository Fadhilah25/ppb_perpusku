class BorrowTransaction {
  final int? id;
  final int bookId;
  final int memberId;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final double fine;
  final String status; // 'borrowed' or 'returned'
  final String? notes;

  BorrowTransaction({
    this.id,
    required this.bookId,
    required this.memberId,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    this.fine = 0.0,
    required this.status,
    this.notes,
  });

  BorrowTransaction copy({
    int? id,
    int? bookId,
    int? memberId,
    DateTime? borrowDate,
    DateTime? dueDate,
    DateTime? returnDate,
    double? fine,
    String? status,
    String? notes,
  }) => BorrowTransaction(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    memberId: memberId ?? this.memberId,
    borrowDate: borrowDate ?? this.borrowDate,
    dueDate: dueDate ?? this.dueDate,
    returnDate: returnDate ?? this.returnDate,
    fine: fine ?? this.fine,
    status: status ?? this.status,
    notes: notes ?? this.notes,
  );

  static BorrowTransaction fromMap(Map<String, dynamic> map) =>
      BorrowTransaction(
        id: map['id'] as int?,
        bookId: map['book_id'] as int,
        memberId: map['member_id'] as int,
        borrowDate: DateTime.parse(map['borrow_date'] as String),
        dueDate: DateTime.parse(map['due_date'] as String),
        returnDate: map['return_date'] != null
            ? DateTime.parse(map['return_date'] as String)
            : null,
        fine: (map['fine'] as num?)?.toDouble() ?? 0.0,
        status: map['status'] as String,
        notes: map['notes'] as String?,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'book_id': bookId,
    'member_id': memberId,
    'borrow_date': borrowDate.toIso8601String(),
    'due_date': dueDate.toIso8601String(),
    'return_date': returnDate?.toIso8601String(),
    'fine': fine,
    'status': status,
    'notes': notes,
  };

  bool get isOverdue {
    if (status == 'returned') return false;
    return DateTime.now().isAfter(dueDate);
  }

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  double calculateFine({double finePerDay = 1000.0}) {
    if (!isOverdue) return 0.0;
    return daysOverdue * finePerDay;
  }
}
