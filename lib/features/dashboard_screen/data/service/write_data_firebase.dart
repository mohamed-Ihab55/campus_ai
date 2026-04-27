import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDoctor extends StatelessWidget {
  final String name;
  final String department;
  final int avatarColor;
  final String room;
  final String initials;
  final String title;

  const AddDoctor({super.key, required this.name, required this.department, required this.avatarColor, required this.room, required this.initials, required this.title});

  @override
  Widget build(BuildContext context) {
    // Create a CollectionReference called users that references the firestore collection
    CollectionReference users = FirebaseFirestore.instance.collection('doctors');

    Future<void> addUser() {
      // Call the user's CollectionReference to add a new user
      return users
          .add({
            'name': name,
            'department': department,
            'initials': initials,
            'avatarColor': avatarColor,
            'room': room,
            'title': title,
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }

    return Column(
      children: [
        TextButton(
          onPressed: addUser,
          child: Text(
            "Add doctor",
          ),
        ),
      ],
    );
  }
}