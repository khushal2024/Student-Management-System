import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfile extends StatefulWidget {
  final String email;

  UserProfile({
    required this.email,
  });

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool isAttendanceMarked = false;
  String lastMarkedDate = '';
  File? _image;
  String? enteredText;

  @override
  void initState() {
    super.initState();
    checkAttendanceMarked();
  }

  Future<void> checkAttendanceMarked() async {
    final QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('userId', isEqualTo: widget.email)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (attendanceSnapshot.docs.isNotEmpty) {
      final Map<String, dynamic> data =
          attendanceSnapshot.docs.first.data() as Map<String, dynamic>;
      final String markedDate = data['date'];
      final DateTime today = DateTime.now();
      final DateTime lastMarked = DateTime.parse(markedDate);

      if (today.year == lastMarked.year &&
          today.month == lastMarked.month &&
          today.day == lastMarked.day) {
        setState(() {
          isAttendanceMarked = true;
          lastMarkedDate = markedDate;
        });
      }
    }
  }

  Future<void> markAttendance() async {
    if (isAttendanceMarked) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Attendance'),
          content: Text('Attendance has already been marked for today.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      final String currentDate = DateTime.now().toString();
      await FirebaseFirestore.instance.collection('attendance').add({
        'userId': widget.email,
        'date': currentDate,
        'status': 'Present',
      });

      setState(() {
        isAttendanceMarked = true;
        lastMarkedDate = currentDate;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Attendance'),
          content: Text('Attendance marked successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> markLeave() async {
    final String currentDate = DateTime.now().toString();
    await FirebaseFirestore.instance.collection('attendance').add({
      'userId': widget.email,
      'date': currentDate,
      'status': 'Leave',
    });

    setState(() {
      isAttendanceMarked = true;
      lastMarkedDate = currentDate;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave'),
        content: Text('Leave marked successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> showAttendanceData() async {
    final QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('userId', isEqualTo: widget.email)
        .get();

    if (attendanceSnapshot.docs.isNotEmpty) {
      List<String> attendanceList = [];

      attendanceSnapshot.docs.forEach((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final String date = data['date'];
        final String status = data['status'];
        attendanceList.add('Date: $date, Status: $status');
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Attendance Data'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children:
                attendanceList.map((attendance) => Text(attendance)).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Attendance Data'),
          content: Text('No attendance data found for the user.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _makeAppeal() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Make Appeal'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                enteredText = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter your appeal',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (enteredText != null && enteredText!.isNotEmpty) {
                  final currentDate = DateTime.now().toString();
                  final appealData = {
                    'date': currentDate,
                    'text': enteredText,
                  };

                  final userDoc = FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.email);
                  final userDocSnapshot = await userDoc.get();

                  if (userDocSnapshot.exists) {
                    final userData = userDocSnapshot.data();
                    List<Map<String, dynamic>> appeals =
                        userData!['appeals'] ?? [];
                    appeals.add(appealData);

                    await userDoc.update({'appeals': appeals});
                  } else {
                    await userDoc.set({
                      'appeals': [appealData]
                    });
                  }

                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Appeal'),
                      content: Text('Appeal submitted successfully.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Submit'),
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
        title: const Text('User Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Make Appeal') {
                _makeAppeal();
              } else if (value == 'View Attendance') {
                showAttendanceData();
              } else if (value == 'Mark Leave') {
                markLeave();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'Make Appeal',
                  child: Text('Make Appeal'),
                ),
                PopupMenuItem<String>(
                  value: 'View Attendance',
                  child: Text('View Attendance'),
                ),
                PopupMenuItem<String>(
                  value: 'Mark Leave',
                  child: Text('Mark Leave'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 60.0,
              backgroundImage: _image != null ? FileImage(_image!) : null,
              child: _image == null
                  ? IconButton(
                      icon: Icon(Icons.add_a_photo),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Choose Image'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _pickImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                                child: Text('Camera'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _pickImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                                child: Text('Gallery'),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : null,
            ),
            SizedBox(height: 16.0),
            Text(
              'Email: ${widget.email}',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            if (isAttendanceMarked)
              Text(
                'Attendance marked for $lastMarkedDate',
                style: TextStyle(fontSize: 16.0),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isAttendanceMarked ? null : markAttendance,
              child: Text('Mark Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
