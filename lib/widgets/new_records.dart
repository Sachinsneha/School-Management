import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:school_management/data/categories.dart';
import 'package:school_management/models/category.dart';

class NewRecordsscreen extends StatefulWidget {
  const NewRecordsscreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _NewRecords();
  }
}

class _NewRecords extends State<NewRecordsscreen> {
  final _formkey = GlobalKey<FormState>();
  var _enteredname = "";
  var _enteredid = 1;
  var _enteredaddress = "";
  var _enteredfee = 0.0;
  var _enterefphone = 1;
  var _selectedcategory = categories[Categories.Computerprogramming]!;
  var _issending = false;

  void _saverecords() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      setState(() {
        _issending = true;
      });
      final url = Uri.https('classproject-bf107-default-rtdb.firebaseio.com',
          'Student-record.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredname,
            'studentid': _enteredid,
            'subject': _selectedcategory.title,
            'address': _enteredaddress,
            'phoneNumber': _enterefphone,
            'feePaid': _enteredfee,
          },
        ),
      );
      print(response.body);
      print(response.statusCode);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
      //    id: DateTime.now().timeZoneName,
      //    name: _enteredname,
      //   subject: _selectedcategory,
      //   studentid: _enteredid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new Record"),
      ),
      body: Padding(
          padding: EdgeInsets.all(12),
          child: Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        maxLength: 50,
                        decoration: const InputDecoration(
                          label: Text('Name'),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim().length <= 4 ||
                              value.trim().length > 50) {
                            return 'Please input valid name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredname = value!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text("Student Id"),
                        ),
                        initialValue: _enteredid.toString(),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Please input valid Student ID';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredid = int.parse(value!);
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        maxLength: 50,
                        decoration: InputDecoration(
                          label: Text("Address"),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim().length <= 4 ||
                              value.trim().length > 50) {
                            return 'Please input valid name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredaddress = value!;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text("Phone Number"),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Please input valid phone number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enterefphone = int.parse(value!);
                        },
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text("Fee Paid"),
                        ),
                        initialValue: _enteredfee.toString(),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Field cannot blank';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredfee = double.parse(value!);
                        },
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      DropdownButtonFormField(
                          value: _selectedcategory,
                          decoration: InputDecoration(label: Text('Subject')),
                          items: [
                            for (final category in categories.entries)
                              DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(category.value.title)
                                  ],
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedcategory = value!;
                            });
                          }),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: _issending
                                  ? null
                                  : () {
                                      _formkey.currentState!.reset();
                                    },
                              child: Text('Reset')),
                          const SizedBox(
                            width: 5,
                          ),
                          ElevatedButton(
                            onPressed: _issending ? null : _saverecords,
                            child: _issending
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(),
                                  )
                                : const Text('Submit'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ))),
    );
  }
}
