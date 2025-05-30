import 'dart:convert';

import 'package:contacts/models.dart';
import 'package:http/http.dart' as http;



class ContactController {
  List<ContactModel> contactList = [];

  Future<void> fetchDatabase() async {

    final url = Uri.parse('http://192.168.1.14/nextgen_contacts/get_contacts.php');

    print(url);

    try {
      print(url);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        final decodedData = jsonDecode(response.body);
        print(response.body);

        if (decodedData is List) {
          contactList = decodedData.map<ContactModel>((i) => ContactModel.fromJson(i)).toList();
        } else {
          contactList = [ContactModel.fromJson(decodedData)];
        }
      } else {
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }
}



