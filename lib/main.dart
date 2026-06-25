import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'features/auth/auth_view_model.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/sync_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          return MaterialApp(
            title: 'Caja Arequipa - Fuerza de Ventas',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            // Simple session routing
            home: authVM.isSuccess ? const DashboardScreen() : const LoginScreen(),
          );
        },
      ),
    );
  }
}
