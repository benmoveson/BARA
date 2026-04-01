import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/sale_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/activity_provider.dart';
import 'ui/auth/sign_in_screen.dart';
import 'ui/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAg0PgQ51d2TYGO5PFLeBIr89WieTK-FeM",
      authDomain: "bara-baaa5.firebaseapp.com",
      projectId: "bara-baaa5",
      storageBucket: "bara-baaa5.firebasestorage.app",
      messagingSenderId: "898364090449",
      appId: "1:898364090449:web:0000000000000000000000",
    ),
  );

  await Hive.initFlutter();
  await Hive.openBox('user');
  await Hive.openBox('settings');

  runApp(const BARAApp());
}

class BARAApp extends StatelessWidget {
  const BARAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: MaterialApp(
        title: 'BARA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF1565C0),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            primary: const Color(0xFF1565C0),
            secondary: const Color(0xFFFFA000),
            surface: const Color(0xFFFFFFFF),
            error: const Color(0xFFD32F2F),
          ),
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.status == AuthStatus.initial ||
                authProvider.status == AuthStatus.loading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (authProvider.isAuthenticated) {
              return const MainShell();
            }

            return const SignInScreen();
          },
        ),
      ),
    );
  }
}
