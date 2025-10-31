import '../database/database_helper.dart';
import '../models/book.dart';
import '../models/member.dart';
import '../models/transaction.dart';

class SeedData {
  static Future<void> seedBooks() async {
    final db = DatabaseHelper.instance;

    // Cek apakah sudah ada data
    final existingBooks = await db.readAllBooks();
    if (existingBooks.isNotEmpty) {
      print('Data buku sudah ada (${existingBooks.length} buku)');
      return;
    }

    // Data buku dummy
    final books = [
      Book(
        title: 'Laskar Pelangi',
        author: 'Andrea Hirata',
        isbn: '9789793062792',
        category: 'Fiksi',
        stock: 5,
        description:
            'Novel tentang perjuangan anak-anak Belitung untuk mendapatkan pendidikan',
      ),
      Book(
        title: 'Bumi Manusia',
        author: 'Pramoedya Ananta Toer',
        isbn: '9789799731234',
        category: 'Fiksi',
        stock: 3,
        description:
            'Bagian pertama dari Tetralogi Buru, mengisahkan kehidupan Minke',
      ),
      Book(
        title: 'Ronggeng Dukuh Paruk',
        author: 'Ahmad Tohari',
        isbn: '9786020822143',
        category: 'Fiksi',
        stock: 4,
        description: 'Kisah Srintil, seorang ronggeng dari Dukuh Paruk',
      ),
      Book(
        title: 'Negeri 5 Menara',
        author: 'Ahmad Fuadi',
        isbn: '9789792248982',
        category: 'Fiksi',
        stock: 6,
        description: 'Perjalanan enam pemuda menuntut ilmu di pondok pesantren',
      ),
      Book(
        title: 'Sang Pemimpi',
        author: 'Andrea Hirata',
        isbn: '9789793062808',
        category: 'Fiksi',
        stock: 4,
        description:
            'Sekuel Laskar Pelangi, kisah Ikal dan Arai mengejar mimpi',
      ),
      Book(
        title: 'Sapiens: A Brief History of Humankind',
        author: 'Yuval Noah Harari',
        isbn: '9780062316097',
        category: 'Sejarah',
        stock: 5,
        description:
            'Sejarah singkat umat manusia dari Homo Sapiens hingga era modern',
      ),
      Book(
        title: 'A Brief History of Time',
        author: 'Stephen Hawking',
        isbn: '9780553380163',
        category: 'Sains',
        stock: 3,
        description:
            'Penjelasan tentang alam semesta, waktu, dan teori relativitas',
      ),
      Book(
        title: 'Steve Jobs',
        author: 'Walter Isaacson',
        isbn: '9781451648539',
        category: 'Biografi',
        stock: 4,
        description: 'Biografi lengkap pendiri Apple Inc.',
      ),
      Book(
        title: 'Clean Code',
        author: 'Robert C. Martin',
        isbn: '9780132350884',
        category: 'Teknologi',
        stock: 7,
        description: 'Panduan menulis kode yang bersih dan maintainable',
      ),
      Book(
        title: 'The Lean Startup',
        author: 'Eric Ries',
        isbn: '9780307887894',
        category: 'Non-Fiksi',
        stock: 5,
        description: 'Metodologi membangun startup dengan efisien',
      ),
      Book(
        title: 'Harry Potter dan Batu Bertuah',
        author: 'J.K. Rowling',
        isbn: '9786020822822',
        category: 'Fiksi',
        stock: 8,
        description: 'Petualangan pertama Harry Potter di Hogwarts',
      ),
      Book(
        title: 'The Little Prince',
        author: 'Antoine de Saint-Exupéry',
        isbn: '9780156012195',
        category: 'Anak-anak',
        stock: 6,
        description: 'Kisah seorang pangeran kecil dari planet asteroid',
      ),
      Book(
        title: 'Atomic Habits',
        author: 'James Clear',
        isbn: '9780735211292',
        category: 'Non-Fiksi',
        stock: 10,
        description:
            'Cara mudah membangun kebiasaan baik dan menghilangkan kebiasaan buruk',
      ),
      Book(
        title: 'Thinking, Fast and Slow',
        author: 'Daniel Kahneman',
        isbn: '9780374533557',
        category: 'Sains',
        stock: 4,
        description: 'Pemahaman tentang dua sistem berpikir manusia',
      ),
      Book(
        title: 'One Piece Vol. 1',
        author: 'Eiichiro Oda',
        isbn: '9784088725093',
        category: 'Komik',
        stock: 12,
        description: 'Petualangan Luffy mencari harta karun One Piece',
      ),
      Book(
        title: 'Naruto Vol. 1',
        author: 'Masashi Kishimoto',
        isbn: '9784088728544',
        category: 'Komik',
        stock: 10,
        description: 'Kisah Naruto Uzumaki yang ingin menjadi Hokage',
      ),
      Book(
        title: 'Sejarah Indonesia Modern',
        author: 'M.C. Ricklefs',
        isbn: '9789799101129',
        category: 'Sejarah',
        stock: 3,
        description: 'Sejarah Indonesia dari masa kolonial hingga kemerdekaan',
      ),
      Book(
        title: 'Python Crash Course',
        author: 'Eric Matthes',
        isbn: '9781593279288',
        category: 'Teknologi',
        stock: 6,
        description: 'Panduan praktis belajar pemrograman Python',
      ),
      Book(
        title: 'The Alchemist',
        author: 'Paulo Coelho',
        isbn: '9780062315007',
        category: 'Fiksi',
        stock: 5,
        description: 'Perjalanan seorang penggembala mencari harta karun',
      ),
      Book(
        title: 'Educated',
        author: 'Tara Westover',
        isbn: '9780399590504',
        category: 'Biografi',
        stock: 4,
        description:
            'Memoir tentang seorang wanita yang tumbuh tanpa pendidikan formal',
      ),
    ];

    // Insert semua buku
    for (final book in books) {
      await db.createBook(book);
    }

    print('✅ Berhasil menambahkan ${books.length} buku dummy');
  }

  static Future<void> seedMembers() async {
    final db = DatabaseHelper.instance;

    // Cek apakah sudah ada data
    final existingMembers = await db.readAllMembers();
    if (existingMembers.isNotEmpty) {
      print('Data anggota sudah ada (${existingMembers.length} anggota)');
      return;
    }

    // Data anggota dummy
    final members = [
      Member(
        name: 'Ahmad Fauzi',
        memberId: 'M250001',
        phone: '081234567890',
        email: 'ahmad.fauzi@email.com',
      ),
      Member(
        name: 'Siti Nurhaliza',
        memberId: 'M250002',
        phone: '081234567891',
        email: 'siti.nur@email.com',
      ),
      Member(
        name: 'Budi Santoso',
        memberId: 'M250003',
        phone: '081234567892',
        email: 'budi.santoso@email.com',
      ),
      Member(
        name: 'Dewi Lestari',
        memberId: 'M250004',
        phone: '081234567893',
        email: 'dewi.lestari@email.com',
      ),
      Member(
        name: 'Eko Prasetyo',
        memberId: 'M250005',
        phone: '081234567894',
        email: 'eko.prasetyo@email.com',
      ),
      Member(
        name: 'Fitri Handayani',
        memberId: 'M250006',
        phone: '081234567895',
        email: 'fitri.handayani@email.com',
      ),
      Member(
        name: 'Gunawan Wijaya',
        memberId: 'M250007',
        phone: '081234567896',
        email: 'gunawan.wijaya@email.com',
      ),
      Member(
        name: 'Hani Putri',
        memberId: 'M250008',
        phone: '081234567897',
        email: 'hani.putri@email.com',
      ),
      Member(
        name: 'Indra Kusuma',
        memberId: 'M250009',
        phone: '081234567898',
        email: 'indra.kusuma@email.com',
      ),
      Member(
        name: 'Julia Rahmawati',
        memberId: 'M250010',
        phone: '081234567899',
        email: 'julia.rahmawati@email.com',
      ),
    ];

    // Insert semua anggota
    for (final member in members) {
      await db.createMember(member);
    }

    print('✅ Berhasil menambahkan ${members.length} anggota dummy');
  }

  static Future<void> seedTransactions() async {
    final db = DatabaseHelper.instance;

    // Cek apakah sudah ada data
    final existingTransactions = await db.readAllTransactions();
    if (existingTransactions.isNotEmpty) {
      print(
        'Data transaksi sudah ada (${existingTransactions.length} transaksi)',
      );
      return;
    }

    final books = await db.readAllBooks();
    final members = await db.readAllMembers();

    if (books.isEmpty || members.isEmpty) {
      print('⚠️ Tambahkan buku dan anggota terlebih dahulu');
      return;
    }

    // Data transaksi dummy (beberapa aktif, beberapa sudah dikembalikan, beberapa terlambat)
    final now = DateTime.now();

    final transactions = [
      // Transaksi aktif (on time)
      BorrowTransaction(
        bookId: books[0].id!,
        memberId: members[0].id!,
        borrowDate: now.subtract(const Duration(days: 3)),
        dueDate: now.add(const Duration(days: 4)),
        status: 'borrowed',
        notes: 'Peminjaman normal',
      ),
      BorrowTransaction(
        bookId: books[1].id!,
        memberId: members[1].id!,
        borrowDate: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 5)),
        status: 'borrowed',
      ),
      // Transaksi terlambat
      BorrowTransaction(
        bookId: books[2].id!,
        memberId: members[2].id!,
        borrowDate: now.subtract(const Duration(days: 12)),
        dueDate: now.subtract(const Duration(days: 2)),
        status: 'borrowed',
        notes: 'Sudah terlambat 2 hari',
      ),
      BorrowTransaction(
        bookId: books[3].id!,
        memberId: members[3].id!,
        borrowDate: now.subtract(const Duration(days: 15)),
        dueDate: now.subtract(const Duration(days: 5)),
        status: 'borrowed',
        notes: 'Terlambat 5 hari',
      ),
      // Transaksi sudah dikembalikan (tepat waktu)
      BorrowTransaction(
        bookId: books[4].id!,
        memberId: members[4].id!,
        borrowDate: now.subtract(const Duration(days: 20)),
        dueDate: now.subtract(const Duration(days: 13)),
        returnDate: now.subtract(const Duration(days: 15)),
        status: 'returned',
        fine: 0,
      ),
      BorrowTransaction(
        bookId: books[5].id!,
        memberId: members[5].id!,
        borrowDate: now.subtract(const Duration(days: 25)),
        dueDate: now.subtract(const Duration(days: 18)),
        returnDate: now.subtract(const Duration(days: 19)),
        status: 'returned',
        fine: 0,
      ),
      // Transaksi dikembalikan terlambat (dengan denda)
      BorrowTransaction(
        bookId: books[6].id!,
        memberId: members[6].id!,
        borrowDate: now.subtract(const Duration(days: 30)),
        dueDate: now.subtract(const Duration(days: 23)),
        returnDate: now.subtract(const Duration(days: 20)),
        status: 'returned',
        fine: 3000, // 3 hari terlambat
        notes: 'Terlambat 3 hari, denda Rp 3.000',
      ),
      BorrowTransaction(
        bookId: books[7].id!,
        memberId: members[7].id!,
        borrowDate: now.subtract(const Duration(days: 35)),
        dueDate: now.subtract(const Duration(days: 28)),
        returnDate: now.subtract(const Duration(days: 23)),
        status: 'returned',
        fine: 5000, // 5 hari terlambat
        notes: 'Terlambat 5 hari, denda Rp 5.000',
      ),
      // Lebih banyak transaksi aktif
      BorrowTransaction(
        bookId: books[8].id!,
        memberId: members[8].id!,
        borrowDate: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 6)),
        status: 'borrowed',
      ),
      BorrowTransaction(
        bookId: books[9].id!,
        memberId: members[9].id!,
        borrowDate: now,
        dueDate: now.add(const Duration(days: 7)),
        status: 'borrowed',
        notes: 'Baru dipinjam hari ini',
      ),
    ];

    // Insert semua transaksi dan update stok buku
    for (final transaction in transactions) {
      await db.createTransaction(transaction);

      // Update stok buku (kurangi 1)
      final book = await db.readBook(transaction.bookId);
      if (book != null && transaction.status == 'borrowed') {
        await db.updateBook(book.copy(stock: book.stock - 1));
      }
    }

    print('✅ Berhasil menambahkan ${transactions.length} transaksi dummy');
  }

  static Future<void> seedAll() async {
    print('🌱 Memulai seed data...\n');

    await seedBooks();
    await seedMembers();
    await seedTransactions();

    print('\n✅ Seeding selesai!');
    print('📚 Data buku, anggota, dan transaksi telah ditambahkan');
  }

  static Future<void> clearAll() async {
    final db = DatabaseHelper.instance;

    // Hapus semua data (HATI-HATI!)
    final transactions = await db.readAllTransactions();
    for (final t in transactions) {
      await db.deleteTransaction(t.id!);
    }

    final books = await db.readAllBooks();
    for (final b in books) {
      await db.deleteBook(b.id!);
    }

    final members = await db.readAllMembers();
    for (final m in members) {
      await db.deleteMember(m.id!);
    }

    print('🗑️ Semua data telah dihapus');
  }
}
