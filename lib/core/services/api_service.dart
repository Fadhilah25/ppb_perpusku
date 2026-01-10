import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/books/models/book.dart';
import '../../features/members/models/member.dart';
import '../../features/transactions/models/transaction.dart' as app;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Update this with your actual API base URL
  static const String baseUrl = 'https://your-api-server.com/api';

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Set auth token if needed
  void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  // ============ BOOKS API ============

  Future<List<Book>> getBooks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/books'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  Future<Book> getBookById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/books/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Book.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching book: $e');
    }
  }

  Future<Book> createBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/books'),
        headers: _headers,
        body: json.encode(book.toJson()),
      );

      if (response.statusCode == 201) {
        return Book.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating book: $e');
    }
  }

  Future<Book> updateBook(int id, Book book) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/books/$id'),
        headers: _headers,
        body: json.encode(book.toJson()),
      );

      if (response.statusCode == 200) {
        return Book.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating book: $e');
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/books/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting book: $e');
    }
  }

  // ============ MEMBERS API ============

  Future<List<Member>> getMembers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/members'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Member.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching members: $e');
    }
  }

  Future<Member> getMemberById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/members/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Member.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching member: $e');
    }
  }

  Future<Member> createMember(Member member) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/members'),
        headers: _headers,
        body: json.encode(member.toJson()),
      );

      if (response.statusCode == 201) {
        return Member.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating member: $e');
    }
  }

  Future<Member> updateMember(int id, Member member) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/members/$id'),
        headers: _headers,
        body: json.encode(member.toJson()),
      );

      if (response.statusCode == 200) {
        return Member.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating member: $e');
    }
  }

  Future<void> deleteMember(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/members/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting member: $e');
    }
  }

  // ============ TRANSACTIONS API ============

  Future<List<app.Transaction>> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => app.Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  Future<app.Transaction> createTransaction(app.Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: _headers,
        body: json.encode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        return app.Transaction.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating transaction: $e');
    }
  }

  Future<app.Transaction> updateTransaction(
    int id,
    app.Transaction transaction,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/transactions/$id'),
        headers: _headers,
        body: json.encode(transaction.toJson()),
      );

      if (response.statusCode == 200) {
        return app.Transaction.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  // ============ SYNC FUNCTIONS ============

  // Sync local data to server
  Future<void> syncToServer({
    List<Book>? books,
    List<Member>? members,
    List<app.Transaction>? transactions,
  }) async {
    try {
      if (books != null) {
        for (var book in books) {
          if (book.id == null) {
            await createBook(book);
          } else {
            await updateBook(book.id!, book);
          }
        }
      }

      if (members != null) {
        for (var member in members) {
          if (member.id == null) {
            await createMember(member);
          } else {
            await updateMember(member.id!, member);
          }
        }
      }

      if (transactions != null) {
        for (var transaction in transactions) {
          if (transaction.id == null) {
            await createTransaction(transaction);
          } else {
            await updateTransaction(transaction.id!, transaction);
          }
        }
      }
    } catch (e) {
      throw Exception('Error syncing to server: $e');
    }
  }

  // Check server connection
  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'), headers: _headers)
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
