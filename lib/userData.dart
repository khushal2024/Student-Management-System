import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDataPage extends StatefulWidget {
  @override
  _AdminDataPageState createState() => _AdminDataPageState();
}

class _AdminDataPageState extends State<AdminDataPage> {
  List<Map<String, dynamic>> _usersData = [];

  Future<void> _getAllUsersData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> usersData = querySnapshot.docs
        .map((document) => document.data() as Map<String, dynamic>)
        .toList();

    setState(() {
      _usersData = usersData;
    });
  }

  void _displayAllUsersData(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('All Users Data'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('List of users:'),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _usersData.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_usersData[index].toString()),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Data'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _getAllUsersData,
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered))
                      return Colors.redAccent; //<-- SEE HERE
                    return null; // Defer to the widget's default.
                  },
                ),
              ),
              //child: Text('Find'),
              child: const Text(
                'Show all User Data',
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Users Data:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _usersData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_usersData[index].toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
