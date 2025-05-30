import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;
  ContactPage(this.contact);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  


  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.contact.displayName),
          backgroundColor: Colors.blue.shade100,
        ),
    
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: widget.contact.photo != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: MemoryImage(widget.contact.photo!),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue,
                        child: Text(
                          widget.contact.displayName.isNotEmpty
                              ? widget.contact.displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(fontSize: 40, color: Colors.white),
                        ),
                      ),
              ),
              SizedBox(height: 16),
              _infoRow('First name', widget.contact.name.first),
              _infoRow('Last name', widget.contact.name.last),
              _infoRow(
                'Phone',
                widget.contact.phones.isNotEmpty ? widget.contact.phones.first.number : 'None',
              ),
              _infoRow(
                'Email',
                widget.contact.emails.isNotEmpty ? widget.contact.emails.first.address : 'None',
              ),
            ],
          ),
        ),
      );

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
