import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GradeCalculatorPage extends StatefulWidget {
  @override
  _GradeCalculatorPageState createState() => _GradeCalculatorPageState();
}

class _GradeCalculatorPageState extends State<GradeCalculatorPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int attendedDays = 0;
  String grade = '';
  int presentCount = 0;
  int leaveCount = 0;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> calculateGrade(String email) async {
    try {
      print('Calculating grade for user: $email');

      DocumentSnapshot userSnapshot =
          await firestore.collection('users').doc(email).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        setState(() {
          String status = userData['status'] ?? '';
          attendedDays = getStatusDays(status);
          grade = calculateGradeFromDays(attendedDays);
        });

        QuerySnapshot attendanceSnapshot = await firestore
            .collection('attendance')
            .where('email', isEqualTo: email)
            .get();

        presentCount = 0;
        leaveCount = 0;
        attendanceSnapshot.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          bool isPresent = data['attended'] ?? false;
          if (isPresent) {
            presentCount++;
          } else {
            leaveCount++;
          }
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Grade Calculated'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attended Days: $attendedDays',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Present Students: $presentCount',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Leave Students: $leaveCount',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Grade: $grade',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

        print('Grade calculated successfully');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('User Not Found'),
              content: Text('User with the provided email does not exist.'),
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

        print('User not found');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while calculating the grade. Please try again later.'),
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

      print('Error calculating grade: $e');
    }
  }

  int getStatusDays(String status) {
    switch (status) {
      case 'Present':
        return 1;
      case 'Late':
        return 0;
      case 'Absent':
        return 0;
      default:
        return 0;
    }
  }

  String calculateGradeFromDays(int attendedDays) {
    if (attendedDays >= 26) {
      return 'A';
    } else if (attendedDays >= 20) {
      return 'B';
    } else if (attendedDays >= 15) {
      return 'C';
    } else if (attendedDays >= 10) {
      return 'D';
    } else {
      return 'F';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Calculator'),
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
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String email = _emailController.text.trim();
                    await calculateGrade(email);
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
                  'Calculate',
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Grade:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                grade,
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Present Students:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                presentCount.toString(),
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Leave Students:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                leaveCount.toString(),
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
