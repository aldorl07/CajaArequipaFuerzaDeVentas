import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'features/auth/auth_oficial_view_model.dart';
import 'features/auth/login_oficial_screen.dart';
import 'features/cartera/cartera_diaria_screen.dart';
import 'features/cartera/cartera_view_model.dart';
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
        ChangeNotifierProvider(create: (_) => AuthOficialViewModel()),
        ChangeNotifierProvider(create: (_) => CarteraViewModel()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: Consumer<AuthOficialViewModel>(
        builder: (context, authOficialVM, _) {
          return MaterialApp(
            title: 'Caja Arequipa - Fuerza de Ventas',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            // Session routing for official portal
            home: authOficialVM.isSuccess ? const CarteraDiariaScreen() : const LoginOficialScreen(),
          );
        },
      ),
    );
  }
}
