// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/login_provider.dart';
import 'providers/home_provider.dart';
import 'providers/camera_provider.dart';
import 'database/database.dart';
import 'routes/routes.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseApp = DatabaseApp();
  await databaseApp.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider(databaseApp)),
        ChangeNotifierProvider(create: (_) => CameraProvider(databaseApp)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nota Clara',
      theme: AppTheme.light,
      initialRoute: '/login',
      routes: Routes.routes,
    );
  }
}
