import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:school_management/data/categories.dart';
import 'package:school_management/models/student_detalis.dart';
import 'package:school_management/widgets/new_records.dart';

class StudentRecord extends StatefulWidget {
  const StudentRecord({Key? key}) : super(key: key);

  @override
  State<StudentRecord> createState() => _StudentRecordState();
}

class _StudentRecordState extends State<StudentRecord> {
  List<StudentDetalis> _records = [];
  List<StudentDetalis> _filteredRecords = [];
  var _isloading = true;
  String? _error;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadrecord();
    _searchController.addListener(_searchRecords);
  }

  void _loadrecord() async {
    final url = Uri.https('classproject-bf107-default-rtdb.firebaseio.com',
        'Student-record.json');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to Fetch data. Please try again";
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isloading = false;
        });
        return;
      }

      final Map<String, dynamic> listofrecord = json.decode(response.body);
      final List<StudentDetalis> _lodedrecord = [];
      for (final record in listofrecord.entries) {
        final category = categories.entries
            .firstWhere(
                (catitem) => catitem.value.title == record.value['subject'])
            .value;
        _lodedrecord.add(StudentDetalis(
          id: record.key,
          name: record.value['name'],
          studentid: record.value['studentid'],
          subject: category,
          address: record.value['address'],
          phoneNumber: record.value['phoneNumber'],
          feePaid: record.value['feePaid'],
        ));
      }
      setState(() {
        _records = _lodedrecord;
        _filteredRecords = _lodedrecord;
        _isloading = false;
      });
    } catch (error) {
      setState(() {
        _error = "Something went wrong! Please try again later.";
      });
    }
  }

  void _addrecord() async {
    await Navigator.of(context).push<StudentDetalis>(
      MaterialPageRoute(
        builder: (ctx) => const NewRecordsscreen(),
      ),
    );
    _loadrecord();
  }

  void _removeitem(StudentDetalis re) async {
    final recordindex = _records.indexOf(re);
    setState(() {
      _records.remove(re);
      _filteredRecords.remove(re);
    });

    final url = Uri.https('classproject-bf107-default-rtdb.firebaseio.com',
        'Student-record/${re.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _records.insert(recordindex, re);
        _filteredRecords.insert(recordindex, re);
      });
    }

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Record deleted'),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () {
          setState(() {
            _records.insert(recordindex, re);
            _filteredRecords.insert(recordindex, re);
          });
        },
      ),
    ));
  }

  void _searchRecords() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecords = _records
          .where((record) => record.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(context) {
    Widget content = const Center(
      child: Text('No Records Yet.'),
    );
    if (_isloading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredRecords.isNotEmpty) {
      content = ListView.builder(
        itemCount: _filteredRecords.length,
        itemBuilder: (ctx, index) => Dismissible(
          background: Container(
            color: Colors.red,
          ),
          onDismissed: (direction) {
            _removeitem(_filteredRecords[index]);
          },
          key: ValueKey(_filteredRecords[index].id),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ExpansionTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${_filteredRecords[index].name}',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '(${_filteredRecords[index].studentid})',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        height: 15,
                        width: 15,
                        color: _filteredRecords[index].subject.color,
                      ),
                      SizedBox(width: 5),
                      Text(_filteredRecords[index].subject.title),
                    ],
                  ),
                ],
              ),
              children: [
                ListTile(
                  title: Text('Address: ${_filteredRecords[index].address}'),
                ),
                ListTile(
                  title: Text(
                      'Phone Number: ${_filteredRecords[index].phoneNumber}'),
                ),
                ListTile(
                  title: Text('Fee Paid: ${_filteredRecords[index].feePaid}'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _addrecord, icon: Icon(Icons.add)),
        ],
        title: Expanded(
          child: Row(
            children: [
              Text('Students Record'),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: Container(
                  width: 150,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: 'Name',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: content,
    );
  }
}
