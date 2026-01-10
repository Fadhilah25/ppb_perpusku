import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:perpusku/features/books/models/book.dart';
import 'package:perpusku/features/members/models/member.dart';
import 'package:perpusku/features/transactions/models/transaction.dart' as app;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'perpusku.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Books table
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        isbn TEXT NOT NULL UNIQUE,
        category TEXT NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        cover_photo TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create Members table
    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        member_id TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        photo TEXT,
        registration_date TEXT NOT NULL
      )
    ''');

    // Create Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        member_id INTEGER NOT NULL,
        borrow_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        return_date TEXT,
        fine REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE,
        FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_books_category ON books(category)');
    await db.execute('CREATE INDEX idx_books_isbn ON books(isbn)');
    await db.execute(
      'CREATE INDEX idx_members_member_id ON members(member_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_status ON transactions(status)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_book_id ON transactions(book_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_member_id ON transactions(member_id)',
    );
  }

  // Books CRUD operations
  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert('books', book.toMap());
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      orderBy: 'title ASC',
    );
    return List.generate(maps.length, (i) => Book.fromMap(maps[i]));
  }

  Future<Book?> getBookById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Book.fromMap(maps.first);
  }

  Future<List<Book>> searchBooks(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'title LIKE ? OR author LIKE ? OR isbn LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
    return List.generate(maps.length, (i) => Book.fromMap(maps[i]));
  }

  Future<List<Book>> getBooksByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'title ASC',
    );
    return List.generate(maps.length, (i) => Book.fromMap(maps[i]));
  }

  Future<List<String>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM books ORDER BY category ASC',
    );
    return List.generate(maps.length, (i) => maps[i]['category'] as String);
  }

  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateBookStock(int bookId, int newStock) async {
    final db = await database;
    return await db.update(
      'books',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  // Members CRUD operations
  Future<int> insertMember(Member member) async {
    final db = await database;
    return await db.insert('members', member.toMap());
  }

  Future<List<Member>> getAllMembers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'members',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  Future<Member?> getMemberById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Member.fromMap(maps.first);
  }

  Future<List<Member>> searchMembers(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'members',
      where: 'name LIKE ? OR member_id LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  Future<int> updateMember(Member member) async {
    final db = await database;
    return await db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await database;
    return await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  // Transactions CRUD operations
  Future<int> insertTransaction(app.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<app.Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, b.title as book_title, m.name as member_name
      FROM transactions t
      LEFT JOIN books b ON t.book_id = b.id
      LEFT JOIN members m ON t.member_id = m.id
      ORDER BY t.borrow_date DESC
    ''');
    return List.generate(maps.length, (i) => app.Transaction.fromMap(maps[i]));
  }

  Future<app.Transaction?> getTransactionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, b.title as book_title, m.name as member_name
      FROM transactions t
      LEFT JOIN books b ON t.book_id = b.id
      LEFT JOIN members m ON t.member_id = m.id
      WHERE t.id = ?
    ''',
      [id],
    );
    if (maps.isEmpty) return null;
    return app.Transaction.fromMap(maps.first);
  }

  Future<List<app.Transaction>> getTransactionsByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, b.title as book_title, m.name as member_name
      FROM transactions t
      LEFT JOIN books b ON t.book_id = b.id
      LEFT JOIN members m ON t.member_id = m.id
      WHERE t.status = ?
      ORDER BY t.borrow_date DESC
    ''',
      [status],
    );
    return List.generate(maps.length, (i) => app.Transaction.fromMap(maps[i]));
  }

  Future<List<app.Transaction>> getTransactionsByMember(int memberId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, b.title as book_title, m.name as member_name
      FROM transactions t
      LEFT JOIN books b ON t.book_id = b.id
      LEFT JOIN members m ON t.member_id = m.id
      WHERE t.member_id = ?
      ORDER BY t.borrow_date DESC
    ''',
      [memberId],
    );
    return List.generate(maps.length, (i) => app.Transaction.fromMap(maps[i]));
  }

  Future<List<app.Transaction>> getTransactionsByBook(int bookId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, b.title as book_title, m.name as member_name
      FROM transactions t
      LEFT JOIN books b ON t.book_id = b.id
      LEFT JOIN members m ON t.member_id = m.id
      WHERE t.book_id = ?
      ORDER BY t.borrow_date DESC
    ''',
      [bookId],
    );
    return List.generate(maps.length, (i) => app.Transaction.fromMap(maps[i]));
  }

  Future<List<app.Transaction>> getOverdueTransactions() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.*, b.title as book_title, m.name as member_name
      FROM transactions t
      LEFT JOIN books b ON t.book_id = b.id
      LEFT JOIN members m ON t.member_id = m.id
      WHERE t.status = 'borrowed' AND t.due_date < ?
      ORDER BY t.due_date ASC
    ''',
      [now],
    );
    return List.generate(maps.length, (i) => app.Transaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(app.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Statistics queries
  Future<Map<String, int>> getStatistics() async {
    final db = await database;

    final totalBooks =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM books'),
        ) ??
        0;

    final totalMembers =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM members'),
        ) ??
        0;

    final activeTransactions =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM transactions WHERE status = 'borrowed'",
          ),
        ) ??
        0;

    final totalTransactions =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM transactions'),
        ) ??
        0;

    return {
      'totalBooks': totalBooks,
      'totalMembers': totalMembers,
      'activeTransactions': activeTransactions,
      'totalTransactions': totalTransactions,
    };
  }

  Future<List<Map<String, dynamic>>> getPopularBooks(int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT b.id, b.title, b.author, COUNT(t.id) as borrow_count
      FROM books b
      LEFT JOIN transactions t ON b.id = t.book_id
      GROUP BY b.id
      ORDER BY borrow_count DESC
      LIMIT ?
    ''',
      [limit],
    );
    return maps;
  }

  Future<List<Map<String, dynamic>>> getMonthlyTransactionStats(
    int year,
    int month,
  ) async {
    final db = await database;
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 1).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        DATE(borrow_date) as date,
        COUNT(*) as count
      FROM transactions
      WHERE borrow_date >= ? AND borrow_date < ?
      GROUP BY DATE(borrow_date)
      ORDER BY date ASC
    ''',
      [startDate, endDate],
    );
    return maps;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
