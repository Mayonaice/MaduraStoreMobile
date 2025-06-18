import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:madura_store_mobile/screens/splash_screen.dart';
import 'package:madura_store_mobile/services/auth_service.dart';
import 'package:madura_store_mobile/services/transaction_service.dart';
import 'package:madura_store_mobile/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TransactionService()),
      ],
      child: const MaduraStoreMobile(),
    ),
  );
}

class MaduraStoreMobile extends StatelessWidget {
  const MaduraStoreMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madura Store Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
} 