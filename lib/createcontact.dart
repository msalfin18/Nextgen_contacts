import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateContactPage extends StatefulWidget {
  const CreateContactPage({super.key});

  @override
  State createState() => _CreateContactPageState();
}

class _CreateContactPageState extends State<CreateContactPage> {
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _surnameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void addContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = Contact()
        ..name.first = _firstNameController.text
        ..name.last = _surnameController.text
        ..organizations = [Organization(company: _companyController.text)]
        ..phones = [Phone(_phoneController.text)];

      await contact.insert();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact added successfully!')),
      );

      // Optionally clear form
      _firstNameController.clear();
      _surnameController.clear();
      _companyController.clear();
      _phoneController.clear();
      setState(() => _selectedImage = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access contacts')),
      );
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              '×',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Colors.blue              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Create contact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color:Colors.blue,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: addContact,
            style: ElevatedButton.styleFrom(
              backgroundColor:Colors.blue     ,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              textStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w400),
              minimumSize: const Size(0, 32),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white),),
          ),
          const SizedBox(width: 12),
          const Text(
            '⋮',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color:Colors.blue     
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPicture() {
    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color:Colors.blue     ,
              shape: BoxShape.circle,
              image: _selectedImage != null
                  ? DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _selectedImage == null
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.image_outlined,
                          color: Colors.white, size: 48),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.blue     ,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add picture',
            style: TextStyle(
              color: Colors.blue     ,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color:Colors.blue     , fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color:Colors.blue     ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color:Colors.blue     , width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4, left: 4),
          child: Text(
            'Phone (Mobile)',
            style: TextStyle(
              fontSize: 12,
              color:Colors.blue     ,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.4)),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Image.network(
                  'https://flagcdn.com/w20/in.png',
                  width: 20,
                  height: 15,
                  fit: BoxFit.cover,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  '+91',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue     ,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _phoneController.clear()),
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhoneText() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Support for multiple phones not implemented')),
          );
        },
        child: const Text(
          'Add phone',
          style: TextStyle(
            fontSize: 14,
            color:Colors.blue,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label tapped')),
          );
        },
        icon: Icon(icon, size: 20 , color: Colors.white,),
        label: Text(label, style: TextStyle(color: Colors.white),),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 12),
              Center(child: _buildAddPicture()),
              const SizedBox(height: 24),
              _buildTextField(
                hintText: 'First name',
                controller: _firstNameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                hintText: 'Surname',
                controller: _surnameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                hintText: 'Company',
                controller: _companyController,
              ),
              const SizedBox(height: 16),
              _buildPhoneInput(),
              _buildAddPhoneText(),
              const SizedBox(height: 24),
              _buildActionButton(Icons.email_outlined, 'Add email'),
              const SizedBox(height: 16),
              _buildActionButton(Icons.cake_outlined, 'Add birthday'),
              const SizedBox(height: 16),
              _buildActionButton(Icons.location_on_outlined, 'Add address'),
              const SizedBox(height: 16),
              _buildActionButton(Icons.label_outline, 'Add to label'),
            ],
          ),
        ),
      ),
    );
  }
}
