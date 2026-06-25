import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'features/auth/auth_oficial_view_model.dart';
import 'features/auth/login_oficial_screen.dart';
import 'features/cartera/cartera_diaria_screen.dart';
import 'features/cartera/cartera_view_model.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/sync_service.dart';
import 'core/services/firebase_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseSeeder.seedDatabase();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
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
