import 'package:flutter/material.dart';
import 'package:perpusku/features/books/screens/book_list_screen.dart';
import 'package:perpusku/features/members/screens/member_list_screen.dart';
import 'package:perpusku/features/transactions/screens/transaction_list_screen.dart';
import 'package:perpusku/features/statistics/screens/statistics_screen.dart';
import 'package:perpusku/core/constants/app_strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    BookListScreen(),
    MemberListScreen(),
    TransactionListScreen(),
    StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: AppStrings.books,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: AppStrings.members,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: AppStrings.transactions,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: AppStrings.statistics,
          ),
        ],
      ),
    );
  }
}
