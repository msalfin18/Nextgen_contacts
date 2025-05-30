import 'package:contacts/homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContactInsertPage extends StatefulWidget {
  String? name;
  String? contact;
  String? location;
  String? enquireFor;
  String? remarks;
  String? priority;
  String? status;

  ContactInsertPage({
    super.key,
    this.name,
    this.contact,
    this.location,
    this.enquireFor,
    this.remarks,
    this.priority,
    this.status,
  });

  @override
  _ContactInsertPageState createState() => _ContactInsertPageState();
}

class _ContactInsertPageState extends State<ContactInsertPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController enquireForController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name ?? '';
    contactController.text = widget.contact ?? '';
    locationController.text = widget.location ?? '';
    enquireForController.text = widget.enquireFor ?? '';
    remarkController.text = widget.remarks ?? '';
    priorityController.text = widget.priority ?? '';
    statusController.text = widget.status ?? '';
  }

  Future<void> insertContact() async {
    final response = await http.post(
      Uri.parse("Contact_API"),
      body: {
        "name": nameController.text,
        "contact": contactController.text,
        "location": locationController.text,
        "enquire_for": enquireForController.text,
        "date": DateTime.now().toString(),
        "remark": remarkController.text,
        "priority": priorityController.text,
        "status": statusController.text,
      },
    );

    final message =
        response.body.contains("success")
            ? "Inserted successfully!"
            : "Insert failed!";
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    if (response.body.contains("success")) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CallLogScreen()),
        (Route<dynamic> route) => false, // This removes all previous routes
      );
    }
  }

  List<String> getPriorityOptions() {
    return ['High', 'Medium', 'Low'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert Contact', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(nameController, 'Name'),
              buildTextField(contactController, 'Contact'),
              buildTextField(locationController, 'Location'),
              buildTextField(enquireForController, 'Enquire For'),
              buildTextField(remarkController, 'Remarks'),
              buildPriorityDropdown(),
              buildTextField(statusController, 'Status'),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      insertContact();
                    }
                  },
                  child: Text('Insert', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.black),
          enabled: true,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          labelText: label,
        ),
        maxLines: label == 'Remarks' ? 5 : 1,
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget buildPriorityDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.white,
        value:
            priorityController.text.isNotEmpty ? priorityController.text : null,
        decoration: InputDecoration(
          labelText: 'Priority',
          labelStyle: TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
        items:
            getPriorityOptions().map((String priority) {
              return DropdownMenuItem<String>(
                value: priority,
                child: Text(priority),
              );
            }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            priorityController.text = newValue!;
          });
        },
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? 'Please select Priority'
                    : null,
      ),
    );
  }
}
