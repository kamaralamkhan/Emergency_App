import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';

class MyEmergencyPage extends StatefulWidget {
  @override
  _MyEmergencyPageState createState() => _MyEmergencyPageState();
}

class _MyEmergencyPageState extends State<MyEmergencyPage> {
  TextEditingController _emergencyNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _emergencyNumberController,
              decoration: InputDecoration(labelText: 'Emergency Contact Number'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String newEmergencyNumber = _emergencyNumberController.text;
                FirebaseDatabase.instance
                    .reference()
                    .child('settings/emergency_settings')
                    .update({'emergencyNumber': newEmergencyNumber}).then((_) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Emergency contact updated')));
                }).catchError((error) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Failed to update emergency contact')));
                });
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
