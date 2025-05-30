import 'dart:collection';
import 'package:contacts/controller.dart';
import 'package:contacts/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class GetContact extends StatefulWidget {
  const GetContact({super.key});

  @override
  State<GetContact> createState() => _GetContactState();
}

class _GetContactState extends State<GetContact> {
  final ContactController _contactController = ContactController();
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = true;
  List<ContactModel>? _contacts;
  Map<String, List<ContactModel>> _groupedContacts = {};
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    fetchData();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    await _contactController.fetchDatabase();
    _contacts = _contactController.contactList;
    _groupedContacts = _groupContacts(_contacts!);
    setState(() {
      isLoading = false;
    });
  }

  Map<String, List<ContactModel>> _groupContacts(List<ContactModel> contacts) {
    Map<String, List<ContactModel>> grouped = SplayTreeMap();
    for (var contact in contacts) {
      final firstLetter = (contact.name?.isNotEmpty ?? false)
          ? contact.name![0].toUpperCase()
          : '#';
      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]!.add(contact);
    }
    return grouped;
  }

  void _filterContacts() {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    List<ContactModel> filtered = _contacts ?? [];

    if (_selectedFilter != null) {
      filtered = filtered
          .where((c) =>
              c.priority?.toLowerCase().trim() ==
              _selectedFilter?.toLowerCase().trim())
          .toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered
          .where((c) => c.name?.toLowerCase().contains(query) ?? false)
          .toList();
    }

    _groupedContacts = _groupContacts(filtered);
    setState(() {});
  }

  Future<void> _callNumberDirectly(String number) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
    if (res == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Direct call failed or permission denied')),
      );
    }
  }

  Widget _buildFilterButton(String label, String? type) {
    final bool isSelected = _selectedFilter == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.blue,
        onSelected: (_) {
          setState(() {
            if (_selectedFilter == type) {
              _selectedFilter = null; // toggle off
            } else {
              _selectedFilter = type;
            }
          });
          _applyFilters();
        },
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Contact List', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      hintText: 'Search contacts',
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      _buildFilterButton("All", null),
                      _buildFilterButton("High", "High"),
                      _buildFilterButton("Medium", "Medium"),
                      _buildFilterButton("Low", "Low"),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: _groupedContacts.entries.map((entry) {
                      final letter = entry.key;
                      final contacts = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Text(
                              letter,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                          ...contacts.map((contactModel) => ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                leading: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.blue.shade200,
                                  child: Text(
                                    (contactModel.name != null &&
                                            contactModel.name!.isNotEmpty)
                                        ? contactModel.name![0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22),
                                  ),
                                ),
                                title: Text(
                                  contactModel.name ?? "",
                                  style:
                                      const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: GestureDetector(
                                  onTap: () {
                                    if (contactModel.contact?.isNotEmpty ?? false) {
                                      _callNumberDirectly(contactModel.contact!);
                                    }
                                  },
                                  child: Text(contactModel.contact?.isNotEmpty ?? false
                                      ? contactModel.contact!
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
                                        if (contactModel.contact?.isNotEmpty ?? false) {
                                          _callNumberDirectly(contactModel.contact!);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('No phone number available')),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
