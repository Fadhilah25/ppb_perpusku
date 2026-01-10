import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:perpusku/features/members/models/member.dart';
import 'package:perpusku/features/members/providers/member_provider.dart';
import 'package:perpusku/core/constants/app_strings.dart';
import 'package:perpusku/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class MemberDetailScreen extends StatefulWidget {
  final int memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  Member? _member;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  Future<void> _loadMember() async {
    setState(() {
      _isLoading = true;
    });

    final provider = context.read<MemberProvider>();
    final member = await provider.getMemberById(widget.memberId);

    setState(() {
      _member = member;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.memberDetail)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_member == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.memberDetail)),
        body: const Center(child: Text('Anggota tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.memberDetail)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage:
                  _member!.photo != null && _member!.photo!.isNotEmpty
                  ? FileImage(File(_member!.photo!))
                  : null,
              child: _member!.photo == null || _member!.photo!.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.textSecondary,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              _member!.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${_member!.memberId}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.phone,
                      AppStrings.memberPhone,
                      _member!.phone,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.calendar_today,
                      AppStrings.registrationDate,
                      DateFormat(
                        'dd MMMM yyyy',
                      ).format(_member!.registrationDate),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
