import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:perpusku/features/members/providers/member_provider.dart';
import 'package:perpusku/features/members/screens/member_form_screen.dart';
import 'package:perpusku/features/members/screens/member_detail_screen.dart';
import 'package:perpusku/features/members/widgets/member_card.dart';
import 'package:perpusku/core/constants/app_strings.dart';
import 'package:perpusku/core/constants/app_colors.dart';
import 'package:perpusku/core/widgets/empty_state.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<MemberProvider>().loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.memberList),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchMember,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<MemberProvider>().setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                context.read<MemberProvider>().setSearchQuery(value);
              },
            ),
          ),
          // Member list
          Expanded(
            child: Consumer<MemberProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(provider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.members.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outlined,
                    title: AppStrings.noData,
                    message:
                        'Belum ada anggota yang terdaftar.\nDaftarkan anggota pertama!',
                    action: ElevatedButton.icon(
                      onPressed: () => _navigateToMemberForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text(AppStrings.addMember),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.members.length,
                    itemBuilder: (context, index) {
                      final member = provider.members[index];
                      return MemberCard(
                        member: member,
                        onTap: () =>
                            _navigateToMemberDetail(context, member.id!),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToMemberForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToMemberForm(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MemberFormScreen()),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToMemberDetail(BuildContext context, int memberId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailScreen(memberId: memberId),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }
}
