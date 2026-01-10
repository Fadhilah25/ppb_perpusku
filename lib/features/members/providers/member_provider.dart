import 'package:flutter/foundation.dart';
import 'package:perpusku/features/members/models/member.dart';
import 'package:perpusku/core/database/database_helper.dart';

class MemberProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Member> _members = [];
  List<Member> _filteredMembers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Member> get members => _filteredMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _members = await _dbHelper.getAllMembers();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMember(Member member) async {
    try {
      final id = await _dbHelper.insertMember(member);
      final newMember = member.copyWith(id: id);
      _members.add(newMember);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMember(Member member) async {
    try {
      await _dbHelper.updateMember(member);
      final index = _members.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        _members[index] = member;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMember(int id) async {
    try {
      await _dbHelper.deleteMember(id);
      _members.removeWhere((m) => m.id == id);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Member?> getMemberById(int id) async {
    try {
      return await _dbHelper.getMemberById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMembers = _members;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredMembers = _filteredMembers.where((member) {
        final query = _searchQuery.toLowerCase();
        return member.name.toLowerCase().contains(query) ||
            member.memberId.toLowerCase().contains(query) ||
            member.phone.toLowerCase().contains(query);
      }).toList();
    }
  }
}
