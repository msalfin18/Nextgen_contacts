import 'package:contacts/contacts.dart';
import 'package:contacts/flu_co.dart' show FlutterContactsExample;
import 'package:contacts/get_contact.dart';
import 'package:contacts/homepage.dart';
import 'package:flutter/material.dart';

class Bottombarr extends StatefulWidget {
  const Bottombarr({super.key});

  @override
  State<Bottombarr> createState() => _BottombarrState();
}

class _BottombarrState extends State<Bottombarr> {
  int currentSelectedIndex = 0;

  final _pages = [
    CallLogScreen(), // 0
    GetContact(), // 1
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentSelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: Colors.blue.withOpacity(0.2),
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
        currentIndex: currentSelectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (newIndex) {
          setState(() {
            currentSelectedIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_callback_rounded, size: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone_sharp, size: 30),
            label: '',
          ),
        ],
      ),
    );
  }
}
