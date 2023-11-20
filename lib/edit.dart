import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAttendancePage extends StatefulWidget {
  @override
  _AdminAttendancePageState createState() => _AdminAttendancePageState();
}

class _AdminAttendancePageState extends State<AdminAttendancePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> deleteAttendance(String name) async {
    try {
      print('Deleting attendance for email: $name');

      QuerySnapshot querySnapshot = await firestore
          .collection('attendance')
          .where('email', isEqualTo: email)
          .get();

      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      if (documents.isNotEmpty) {
        for (QueryDocumentSnapshot document in documents) {
          String documentId = document.reference.id;

          // Example code to delete attendance in Firestore
          await firestore.collection('user').doc(documentId).delete();
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('User deleted successfully.'),
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

        print('User deleted successfully');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('No User Found'),
              content: Text(
                  'No User records found for the provided name.'),
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

        print('No user records found for the provided name');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while deleting user. Please try again later.'),
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

      print('Error deleting user: $e');
    }
  }

  // Future<void> editAttendance(String email, String date, String status) async {
  //   try {
  //     print('Editing attendance for email: $email and date: $date');

  //     QuerySnapshot querySnapshot = await firestore
  //         .collection('attendance')
  //         .where('email', isEqualTo: email)
  //         .where('date', isEqualTo: date)
  //         .get();

  //     List<QueryDocumentSnapshot> documents = querySnapshot.docs;

  //     if (documents.isNotEmpty) {
  //       for (QueryDocumentSnapshot document in documents) {
  //         String documentId = document.reference.id;

  //         // Example code to update attendance status in Firestore
  //         await firestore
  //             .collection('attendance')
  //             .doc(documentId)
  //             .update({'status': status});
  //       }

  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text('Success'),
  //             content: Text('Attendance updated successfully.'),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context); // Close the dialog
  //                 },
  //                 child: Text('OK'),
  //               ),
  //             ],
  //           );
  //         },
  //       );

  //       print('Attendance updated successfully');
  //     } else {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text('No Attendance Found'),
  //             content: Text(
  //                 'No attendance records found for the provided email and date.'),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context); // Close the dialog
  //                 },
  //                 child: Text('OK'),
  //               ),
  //             ],
  //           );
  //         },
  //       );

  //       print('No attendance records found for the provided email and date');
  //     }
  //   } catch (e) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Error'),
  //           content: Text(
  //               'An error occurred while editing attendance. Please try again later.'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context); // Close the dialog
  //               },
  //               child: Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );

  //     print('Error editing attendance: $e');
  //   }
  // }

  // Future<void> addAttendance(String email, String date, String status) async {
  //   try {
  //     print('Adding attendance for email: $email and date: $date');

  //     // Example code to add attendance in Firestore
  //     await firestore.collection('attendance').add({
  //       'email': email,
  //       'date': date,
  //       'status': status,
  //     });

  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Success'),
  //           content: Text('Attendance added successfully.'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context); // Close the dialog
  //               },
  //               child: Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );

  //     print('Attendance added successfully');
  //   } catch (e) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Error'),
  //           content: Text(
  //               'An error occurred while adding attendance. Please try again later.'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context); // Close the dialog
  //               },
  //               child: Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );

  //     print('Error adding attendance: $e');
  //   }
  // }

  // @override
  // void dispose() {
  //   _emailController.dispose();
  //   _dateController.dispose();
  //   _statusController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage user'),
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
                  labelText: 'name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              // ),
              // TextFormField(
              //   controller: _dateController,
              //   decoration: InputDecoration(
              //     labelText: 'Date (YYYY-MM-DD)',
              //   ),
              //   validator: (value) {
              //     if (value!.isEmpty) {
              //       return 'Please enter the date';
              //     }
              //     return null;
              //   },
              // ),
              // TextFormField(
              //   controller: _statusController,
              //   decoration: InputDecoration(
              //     labelText: 'Status',
              //   ),
              //   validator: (value) {
              //     if (value!.isEmpty) {
              //       return 'Please enter the status';
              //     }
              //     return null;
              //   },
              // ),
              // SizedBox(height: 16.0),
              // ElevatedButton(
              //   onPressed: () {
              //     if (_formKey.currentState!.validate()) {
              //       String email = _emailController.text.trim();
              //       String date = _dateController.text.trim();
              //       String status = _statusController.text.trim();
              //       addAttendance(email, date, status);
              //     }
              //   },
              //   style: ButtonStyle(
              //     overlayColor: MaterialStateProperty.resolveWith<Color?>(
              //       (Set<MaterialState> states) {
              //         if (states.contains(MaterialState.hovered))
              //           return Colors.redAccent; //<-- SEE HERE
              //         return null; // Defer to the widget's default.
              //       },
              //     ),
              //   ),
              //   //child: Text('Find'),
              //   child: const Text(
              //     'Add Attendance',
              //   ),
              // ),
              // SizedBox(height: 16.0),
              // ElevatedButton(
              //   onPressed: () {
              //     if (_formKey.currentState!.validate()) {
              //       String email = _emailController.text.trim();
              //       String date = _dateController.text.trim();
              //       String status = _statusController.text.trim();
              //       editAttendance(email, date, status);
              //     }
              //   },
              //   style: ButtonStyle(
              //     overlayColor: MaterialStateProperty.resolveWith<Color?>(
              //       (Set<MaterialState> states) {
              //         if (states.contains(MaterialState.hovered))
              //           return Colors.redAccent; //<-- SEE HERE
              //         return null; // Defer to the widget's default.
              //       },
              //     ),
              //   ),
              //   //child: Text('Find'),
              //   child: const Text(
              //     'Edit Attendance',
              //   ),
              // ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String email = _emailController.text.trim();
                    String date = _dateController.text.trim();
                    deleteAttendance(email, date);
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
                  'Delete Attenance',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
