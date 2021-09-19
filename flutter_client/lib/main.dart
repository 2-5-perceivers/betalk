import 'package:betalk/data_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';

void main() => runApp(const betalkApp());

// ignore: camel_case_types
class betalkApp extends StatelessWidget {
  const betalkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => DataProvider(),
      dispose: (_, DataProvider instance) => instance.dispose(),
      child: MaterialApp(
        title: 'betalk',
        themeMode: ThemeMode.system,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.deepPurple,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple[400]!, secondary: Colors.green[400]!),
        ),
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
