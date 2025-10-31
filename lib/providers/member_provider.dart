import 'package:flutter/foundation.dart';
import '../models/member.dart';
import '../database/database_helper.dart';

class MemberProvider extends ChangeNotifier {
  List<Member> _members = [];
  bool _isLoading = false;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;

  Future<void> loadMembers() async {
    _isLoading = true;
    notifyListeners();

    _members = await DatabaseHelper.instance.readAllMembers();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMember(Member member) async {
    _isLoading = true;
    notifyListeners();

    await DatabaseHelper.instance.createMember(member);
    await loadMembers();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateMember(Member member) async {
    _isLoading = true;
    notifyListeners();

    await DatabaseHelper.instance.updateMember(member);
    await loadMembers();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteMember(int id) async {
    _isLoading = true;
    notifyListeners();

    await DatabaseHelper.instance.deleteMember(id);
    await loadMembers();

    _isLoading = false;
    notifyListeners();
  }

  Future<Member?> findMemberByMemberId(String memberId) async {
    return await DatabaseHelper.instance.findMemberByMemberId(memberId);
  }

  String generateMemberId() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final count = _members.length + 1;
    return 'M$year${count.toString().padLeft(4, '0')}';
  }
}
