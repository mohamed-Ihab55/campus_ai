import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CollectionReference doctors = FirebaseFirestore.instance.collection(
    'doctors',
  );

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController initialsController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController avatarColorController = TextEditingController();

  bool isLoading = false;

  Future<void> addDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await doctors.add({
        'name': nameController.text.trim(),
        'department': departmentController.text.trim(),
        'initials': initialsController.text.trim(),
        'room': roomController.text.trim(),
        'title': titleController.text.trim(),
        'avatarColor': int.parse(avatarColorController.text.trim()),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor Added Successfully")),
      );

      nameController.clear();
      departmentController.clear();
      initialsController.clear();
      roomController.clear();
      titleController.clear();
      avatarColorController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Required Field";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    departmentController.dispose();
    initialsController.dispose();
    roomController.dispose();
    titleController.dispose();
    avatarColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Doctor"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildField(label: "Doctor Name", controller: nameController),
              buildField(label: "Department", controller: departmentController),
              buildField(label: "Initials", controller: initialsController),
              buildField(label: "Room", controller: roomController),
              buildField(label: "Title", controller: titleController),
              buildField(
                label: "Avatar Color (Number)",
                controller: avatarColorController,
                type: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : addDoctor,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Doctor", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
