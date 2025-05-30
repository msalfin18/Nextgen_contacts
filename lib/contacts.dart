import 'package:flutter/material.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts = [];
  bool _isLoading = false;

  Future<void> _loadContacts() async {
    if (await Permission.contacts.request().isGranted) {
      setState(() => _isLoading = true);
      final contacts = await FastContacts.getAllContacts();

      contacts.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Contacts permission is required.")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Contacts'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadContacts,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? Center(child: Text('No contacts found.'))
              : ListView.separated(
                  padding: EdgeInsets.all(12),
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    final phones = contact.phones.map((e) => e.number).join(', ');
                    final emails = contact.emails.map((e) => e.address).join(', ');

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
  radius: 24,
  backgroundColor: Colors.blue,
  child: Text(
    contact.displayName.isNotEmpty
        ? contact.displayName[0].toUpperCase()
        : '?',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  ),
),

                        title: Text(
                          contact.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (phones.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text("$phones"),
                              ),
                            if (emails.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text("$emails"),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
