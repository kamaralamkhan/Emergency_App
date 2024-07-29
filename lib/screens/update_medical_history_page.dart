import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UpdateMedicalHistoryPage extends StatefulWidget {
  @override
  _UpdateMedicalHistoryPageState createState() => _UpdateMedicalHistoryPageState();
}

class _UpdateMedicalHistoryPageState extends State<UpdateMedicalHistoryPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Medical History'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bloodTypeController,
              decoration: InputDecoration(labelText: 'Blood Type'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _allergiesController,
              decoration: InputDecoration(labelText: 'Allergies'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save medical history to Firebase Realtime Database
                saveMedicalHistory();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void saveMedicalHistory() {
    String name = _nameController.text.trim();
    String age = _ageController.text.trim();
    String bloodType = _bloodTypeController.text.trim();
    String allergies = _allergiesController.text.trim();

    // Create a reference to the 'medical_history' node in Firebase Database
    DatabaseReference medicalHistoryRef = FirebaseDatabase.instance.reference().child('medical_history');

    // Push the medical history data to Firebase
    medicalHistoryRef.push().set({
      'name': name,
      'age': age,
      'bloodType': bloodType,
      'allergies': allergies,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medical history updated')));
      // Clear text field controllers after successful submission
      _nameController.clear();
      _ageController.clear();
      _bloodTypeController.clear();
      _allergiesController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update medical history')));
    });
  }
}
