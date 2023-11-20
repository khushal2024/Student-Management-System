import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserReportPage extends StatefulWidget {
  @override
  _UserReportPageState createState() => _UserReportPageState();
}

class _UserReportPageState extends State<UserReportPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> attendanceList = [];

  Future<void> generateReport(
      String email, String fromDate, String toDate) async {
    try {
      print('Generating report for user: $email, from $fromDate to $toDate');

      QuerySnapshot querySnapshot = await firestore
          .collection('attendance')
          .where('email', isEqualTo: email)
          .where('date', isGreaterThanOrEqualTo: fromDate)
          .where('date', isLessThanOrEqualTo: toDate)
          .get();

      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      setState(() {
        attendanceList =
            documents.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Report Generated'),
            content: Text('Report generated successfully.'),
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

      print('Report generated successfully');
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while generating the report. Please try again later.'),
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

      print('Error generating report: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Attendance Report'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'User Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the user email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fromDateController,
                decoration: InputDecoration(
                  labelText: 'From Date (YYYY-MM-DD)',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the from date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _toDateController,
                decoration: InputDecoration(
                  labelText: 'To Date (YYYY-MM-DD)',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the to date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String email = _emailController.text.trim();
                    String fromDate = _fromDateController.text.trim();
                    String toDate = _toDateController.text.trim();
                    await generateReport(email, fromDate, toDate);
                  }
                },
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
                  'Generate Report',
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Report:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  itemCount: attendanceList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('Email: ${attendanceList[index]['email']}'),
                      subtitle: Text(
                          'Date: ${attendanceList[index]['date']}, Status: ${attendanceList[index]['status']}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
