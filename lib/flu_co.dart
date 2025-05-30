import 'package:contacts/createcontact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:collection';
import 'package:permission_handler/permission_handler.dart';

class FlutterContactsExample extends StatefulWidget {
  @override
  _FlutterContactsExampleState createState() => _FlutterContactsExampleState();
}

class _FlutterContactsExampleState extends State<FlutterContactsExample> {
  List<Contact>? _contacts;
  Map<String, List<Contact>> _groupedContacts = {};
  bool _permissionDenied = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
      setState(() {
        _contacts = contacts;
        _groupedContacts = _groupContacts(contacts);
      });
    }
  }

  Map<String, List<Contact>> _groupContacts(List<Contact> contacts) {
    Map<String, List<Contact>> grouped = SplayTreeMap(); // Keeps keys sorted
    for (var contact in contacts) {
      final firstLetter = contact.displayName.isNotEmpty
          ? contact.displayName[0].toUpperCase()
          : '#';
      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]!.add(contact);
    }
    return grouped;
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    if (_contacts == null) return;

    if (query.isEmpty) {
      setState(() {
        _groupedContacts = _groupContacts(_contacts!);
      });
    } else {
      final filtered = _contacts!
          .where((c) => c.displayName.toLowerCase().contains(query))
          .toList();
      setState(() {
        _groupedContacts = _groupContacts(filtered);
      });
    }
  }

  Future<void> _callNumberDirectly(String number) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
    if (res == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Direct call failed or permission denied')),
      );
    }
  }

  void addcontact() async {
    if (await FlutterContacts.requestPermission()) {
      final newContact = Contact()
        ..name.first = 'John'
        ..name.last = 'Doe'
        ..phones = [Phone('1234567890')]
        ..emails = [Email('johndoe@example.com')];

      await newContact.insert();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact added successfully!')),
      );
      _fetchContacts(); // Refresh contacts
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied to access contacts')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: Scaffold(
          backgroundColor: Colors.white,
            appBar: AppBar(
        leading: Icon(Icons.assignment_ind_outlined, color: Colors.blue,size: 35,),
        title: const Text('My Contacts'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateContactPage()));
            },
            child: Icon(Icons.person_add_alt_1_sharp,
                color: Colors.white, size: 30),
          ),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.blue),
                    hintText: 'Search contacts',
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(child: _body()),
            ],
          ),
        ),
      );

  Widget _body() {
    if (_permissionDenied) {
      return Center(
          child: Text(
        'Permission denied',
        style: TextStyle(fontSize: 16, color: Colors.redAccent),
      ));
    }
    if (_groupedContacts.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      children: _groupedContacts.entries.map((entry) {
        final letter = entry.key;
        final contacts = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                letter,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            ),
            ...contacts.map((contact) => ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.blue.shade200,
                    backgroundImage: contact.photo != null
                        ? MemoryImage(contact.photo!)
                        : null,
                    child: contact.photo == null
                        ? Text(
                            contact.displayName.isNotEmpty
                                ? contact.displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22),
                          )
                        : null,
                  ),
                  title: Text(
                    contact.displayName,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: GestureDetector(
                    onTap: () {
                      if (contact.phones.isNotEmpty) {
                        _callNumberDirectly(contact.phones.first.number);
                      }
                    },
                    child: Text(contact.phones.isNotEmpty
                        ? contact.phones.first.number
                        : 'No phone number'),
                  ),
                  trailing: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(500),
                    ),
                    elevation: 2,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: IconButton(
                        icon: Icon(Icons.phone,
                            color: Colors.blue.shade700),
                        onPressed: () {
                          if (contact.phones.isNotEmpty) {
                            _callNumberDirectly(contact.phones.first.number);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('No phone number available')),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  onTap: () async {
                    final fullContact =
                        await FlutterContacts.getContact(contact.id);
                    if (fullContact != null) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => ContactPage(fullContact)),
                      );
                    }
                  },
                ))
          ],
        );
      }).toList(),
    );
  }
}

class ContactPage extends StatelessWidget {
  final Contact contact;
  const ContactPage(this.contact, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.displayName)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade200,
                backgroundImage:
                    contact.photo != null ? MemoryImage(contact.photo!) : null,
                child: contact.photo == null
                    ? Text(
                        contact.displayName.isNotEmpty
                            ? contact.displayName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Phones',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue.shade700),
            ),
            ...contact.phones.map(
              (phone) => ListTile(
                leading: Icon(Icons.phone, color: Colors.blue.shade300),
                title: Text(phone.number),
                subtitle: Text(phone.label.toString() ?? 'Mobile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
