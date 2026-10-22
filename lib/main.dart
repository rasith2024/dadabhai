import 'package:dadabhaitravel/firebase_options.dart';
import 'package:dadabhaitravel/view/pages/admin/admin_package_page.dart';
import 'package:dadabhaitravel/view/pages/dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final bool isIOS =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  runApp(
    AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: LogoColors.primary,
        statusBarIconBrightness:
        isIOS ? Brightness.dark : Brightness.light,
        statusBarBrightness:
        isIOS ? Brightness.light : Brightness.dark,
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const AdminPackagesPage(),
    );
  }
}