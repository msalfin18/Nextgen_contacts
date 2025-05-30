import 'package:contacts/add_contact.dart';
import 'package:contacts/bottombarpage.dart';
import 'package:contacts/contacts.dart';
import 'package:contacts/flu_co.dart';
import 'package:contacts/gpy.dart';
import 'package:contacts/homepage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
           theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3FAF8),
        fontFamily: 'GoogleSans',
        primaryColor: const Color(0xFF1F3A37),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF1F3A37), fontSize: 16),
          bodySmall: TextStyle(color: Color(0xFF1F3A37), fontSize: 12),
          titleLarge: TextStyle(color: Color(0xFF1F3A37), fontSize: 20),
          labelSmall: TextStyle(color: Color(0xFF1F3A37), fontSize: 12),
        ),
      ),
        debugShowCheckedModeBanner: false,
      home: Gpy(), 
    );
  }
}