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

  final TextEditingController initialsController = TextEditingController();

  final TextEditingController roomController = TextEditingController();

  final TextEditingController titleController = TextEditingController();

  bool isLoading = false;

  String? selectedDepartment;
  int? selectedColor;

  final List<String> departments = [
    "CS",
    "Mathematics",
    "Statistics",
    "Physics",
    "Chemistry",
  ];

  final Map<String, Color> avatarColors = {
    "CS": const Color(0xFF2196F3),
    "Mathematics": const Color(0xff000B58),
    "Statistics": const Color(0xFFE91E63),
    "Physics": const Color(0xff006A67),
    "Chemistry": const Color(0xffFF9F00),
  };

  Future<void> addDoctor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await doctors.add({
        'name': nameController.text.trim(),
        'department': selectedDepartment,
        'initials': initialsController.text.trim(),
        'room': roomController.text.trim(),
        'title': titleController.text.trim(),
        'avatarColor': selectedColor,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor Added Successfully")),
      );

      nameController.clear();
      initialsController.clear();
      roomController.clear();
      titleController.clear();

      setState(() {
        selectedDepartment = null;
        selectedColor = null;
      });
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
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

  Widget buildDropdownDepartment() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: selectedDepartment, // ✅ بدل initialValue
        decoration: InputDecoration(
          labelText: "Department",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        items: departments.map((dept) {
          return DropdownMenuItem<String>(value: dept, child: Text(dept));
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedDepartment = value;

            // ✅ يحدد اللون تلقائيًا
            selectedColor = avatarColors[value]?.toARGB32();
          });
        },
        validator: (value) {
          if (value == null) {
            return "Choose Department";
          }
          return null;
        },
      ),
    );
  }

  Widget buildDropdownColor() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<int>(
        initialValue: selectedColor, // ✅ بدل initialValue
        decoration: InputDecoration(
          labelText: "Avatar Color",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        items: avatarColors.entries.map((entry) {
          return DropdownMenuItem<int>(
            value: entry.value.toARGB32(),
            child: Row(
              children: [
                CircleAvatar(radius: 8, backgroundColor: entry.value),
                const SizedBox(width: 10),
                Text(entry.key),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedColor = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return "Choose Color";
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    initialsController.dispose();
    roomController.dispose();
    titleController.dispose();
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
              buildDropdownDepartment(),
              buildField(label: "Initials", controller: initialsController),
              buildField(label: "Room", controller: roomController),
              buildField(label: "Title", controller: titleController),
              buildDropdownColor(),
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
