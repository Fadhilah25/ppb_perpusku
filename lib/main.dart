import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:perpusku/core/theme/app_theme.dart';
import 'package:perpusku/core/constants/app_strings.dart';
import 'package:perpusku/core/services/notification_service.dart';
import 'package:perpusku/features/books/providers/book_provider.dart';
import 'package:perpusku/features/members/providers/member_provider.dart';
import 'package:perpusku/features/transactions/providers/transaction_provider.dart';
import 'package:perpusku/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();
  await NotificationService().scheduleDailyOverdueCheck();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
