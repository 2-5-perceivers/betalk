import 'package:betalk/data_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';

void main() => runApp(const betalkApp());

// ignore: camel_case_types
class betalkApp extends StatelessWidget {
  const betalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => DataProvider(),
      dispose: (_, DataProvider instance) => instance.dispose(),
      child: MaterialApp(
        title: 'BeTalk',
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          brightness: Brightness.light,
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.deepPurple[400],
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
