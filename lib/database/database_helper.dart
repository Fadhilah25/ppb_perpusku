import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';
import '../models/member.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('perpusku.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Books Table
    await db.execute('''
      CREATE TABLE books (
        id $idType,
        title $textType,
        author $textType,
        isbn TEXT,
        category $textType,
        stock $integerType,
        cover_photo TEXT,
        description TEXT,
        created_at TEXT
      )
    ''');

    // Members Table
    await db.execute('''
      CREATE TABLE members (
        id $idType,
        name $textType,
        member_id $textType UNIQUE,
        phone TEXT,
        photo TEXT,
        email TEXT,
        created_at TEXT
      )
    ''');

    // Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        book_id $integerType,
        member_id $integerType,
        borrow_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        return_date TEXT,
        fine $realType DEFAULT 0,
        status $textType,
        notes TEXT,
        FOREIGN KEY (book_id) REFERENCES books (id),
        FOREIGN KEY (member_id) REFERENCES members (id)
      )
    ''');
  }

  // Books CRUD
  Future<Book> createBook(Book book) async {
    final db = await instance.database;
    final id = await db.insert('books', book.toMap());
    return book.copy(id: id);
  }

  Future<Book?> readBook(int id) async {
    final db = await instance.database;
    final maps = await db.query('books', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Book>> readAllBooks() async {
    final db = await instance.database;
    const orderBy = 'title ASC';
    final result = await db.query('books', orderBy: orderBy);
    return result.map((json) => Book.fromMap(json)).toList();
  }

  Future<List<Book>> searchBooks(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'books',
      where: 'title LIKE ? OR author LIKE ? OR isbn LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return result.map((json) => Book.fromMap(json)).toList();
  }

  Future<List<Book>> filterBooksByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'books',
      where: 'category = ?',
      whereArgs: [category],
    );
    return result.map((json) => Book.fromMap(json)).toList();
  }

  Future<int> updateBook(Book book) async {
    final db = await instance.database;
    return db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await instance.database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  // Members CRUD
  Future<Member> createMember(Member member) async {
    final db = await instance.database;
    final id = await db.insert('members', member.toMap());
    return member.copy(id: id);
  }

  Future<Member?> readMember(int id) async {
    final db = await instance.database;
    final maps = await db.query('members', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Member.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Member>> readAllMembers() async {
    final db = await instance.database;
    const orderBy = 'name ASC';
    final result = await db.query('members', orderBy: orderBy);
    return result.map((json) => Member.fromMap(json)).toList();
  }

  Future<Member?> findMemberByMemberId(String memberId) async {
    final db = await instance.database;
    final maps = await db.query(
      'members',
      where: 'member_id = ?',
      whereArgs: [memberId],
    );

    if (maps.isNotEmpty) {
      return Member.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMember(Member member) async {
    final db = await instance.database;
    return db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await instance.database;
    return await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  // Transactions CRUD
  Future<BorrowTransaction> createTransaction(
    BorrowTransaction transaction,
  ) async {
    final db = await instance.database;
    final id = await db.insert('transactions', transaction.toMap());
    return transaction.copy(id: id);
  }

  Future<BorrowTransaction?> readTransaction(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BorrowTransaction.fromMap(maps.first);
    }
    return null;
  }

  Future<List<BorrowTransaction>> readAllTransactions() async {
    final db = await instance.database;
    const orderBy = 'borrow_date DESC';
    final result = await db.query('transactions', orderBy: orderBy);
    return result.map((json) => BorrowTransaction.fromMap(json)).toList();
  }

  Future<List<BorrowTransaction>> getTransactionsByMember(int memberId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'member_id = ?',
      whereArgs: [memberId],
      orderBy: 'borrow_date DESC',
    );
    return result.map((json) => BorrowTransaction.fromMap(json)).toList();
  }

  Future<List<BorrowTransaction>> getActiveTransactions() async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'status = ?',
      whereArgs: ['borrowed'],
      orderBy: 'borrow_date DESC',
    );
    return result.map((json) => BorrowTransaction.fromMap(json)).toList();
  }

  Future<List<BorrowTransaction>> getOverdueTransactions() async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    final result = await db.query(
      'transactions',
      where: 'status = ? AND due_date < ?',
      whereArgs: ['borrowed', now],
      orderBy: 'due_date ASC',
    );
    return result.map((json) => BorrowTransaction.fromMap(json)).toList();
  }

  Future<int> updateTransaction(BorrowTransaction transaction) async {
    final db = await instance.database;
    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Statistics Queries
  Future<List<Map<String, dynamic>>> getPopularBooks({int limit = 10}) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT b.id, b.title, b.author, b.cover_photo, COUNT(t.id) as borrow_count
      FROM books b
      INNER JOIN transactions t ON b.id = t.book_id
      GROUP BY b.id
      ORDER BY borrow_count DESC
      LIMIT ?
    ''',
      [limit],
    );
    return result;
  }

  Future<Map<String, int>> getMonthlyTransactionSummary(
    int year,
    int month,
  ) async {
    final db = await instance.database;
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0).toIso8601String();

    final borrowed = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM transactions
      WHERE borrow_date >= ? AND borrow_date <= ?
    ''',
      [startDate, endDate],
    );

    final returned = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM transactions
      WHERE return_date >= ? AND return_date <= ? AND status = 'returned'
    ''',
      [startDate, endDate],
    );

    return {
      'borrowed': (borrowed.first['count'] as int?) ?? 0,
      'returned': (returned.first['count'] as int?) ?? 0,
    };
  }

  Future<double> getTotalFinesCollected() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT SUM(fine) as total
      FROM transactions
      WHERE status = 'returned' AND fine > 0
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
