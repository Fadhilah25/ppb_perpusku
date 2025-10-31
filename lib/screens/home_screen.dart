import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/member_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/statistics_provider.dart';
import 'books/book_list_screen.dart';
import 'members/member_list_screen.dart';
import 'transactions/transaction_list_screen.dart';
import 'statistics/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BookListScreen(),
    const TransactionListScreen(),
    const MemberListScreen(),
    const StatisticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load data after first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    // Seed data dummy untuk demo (hanya jika database kosong)
    // Dikomen sementara untuk web compatibility
    // await SeedData.seedAll();

    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final statisticsProvider = Provider.of<StatisticsProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      bookProvider.loadBooks(),
      memberProvider.loadMembers(),
      transactionProvider.loadTransactions(),
      statisticsProvider.loadStatistics(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Anggota',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }
}
