import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/member_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/statistics_provider.dart';
import '../services/notification_service.dart';
import '../services/qr_scanner_service.dart';
import 'books/book_list_screen.dart';
import 'members/member_list_screen.dart';
import 'transactions/transaction_list_screen.dart';
import 'statistics/statistics_screen.dart';
import 'transactions/borrow_book_screen.dart';

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

    // Schedule daily overdue check
    await NotificationService.instance.scheduleDailyOverdueCheck();
  }

  Future<void> _quickScanQR() async {
    final scannedCode = await QRScannerService.scanQRCode(context);

    if (scannedCode != null && mounted) {
      // Navigate to borrow screen with scanned book
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BorrowBookScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Code: $scannedCode - Silakan pilih member')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1), // Indigo
                Color(0xFF8B5CF6), // Purple
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _quickScanQR,
              borderRadius: BorderRadius.circular(16),
              child: const Center(
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: BottomAppBar(
          padding: EdgeInsets.zero,
          height: 70,
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  icon: Icons.book_outlined,
                  selectedIcon: Icons.book,
                  label: 'Katalog',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.swap_horiz_outlined,
                  selectedIcon: Icons.swap_horiz,
                  label: 'Transaksi',
                  index: 1,
                ),
                const SizedBox(width: 64), // Space for FAB
                _buildNavItem(
                  icon: Icons.people_outlined,
                  selectedIcon: Icons.people,
                  label: 'Anggota',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.analytics_outlined,
                  selectedIcon: Icons.analytics,
                  label: 'Statistik',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 54,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: 22,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.0,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
