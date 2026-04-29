import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAvatarColorScreen extends StatefulWidget {
  const EditAvatarColorScreen({super.key});

  @override
  State<EditAvatarColorScreen> createState() => _EditAvatarColorScreenState();
}

class _EditAvatarColorScreenState extends State<EditAvatarColorScreen> {
  final CollectionReference doctors = FirebaseFirestore.instance.collection(
    'doctors',
  );

  String? selectedDepartment;
  bool isLoading = false;

  // ✅ استخدم Color بدل int
  final Map<String, Color> departmentColors = {
    "CS": const Color(0xFF2196F3),
    "Mathematics": const Color(0xff000B58),
    "Statistics": const Color(0xFFE91E63),
    "Physics": const Color(0xff006A67),
    "Chemistry": const Color(0xffFF9F00),
  };

  Future<void> updateColor() async {
    if (selectedDepartment == null) return;

    setState(() => isLoading = true);

    try {
      final Color color = departmentColors[selectedDepartment]!;

      final query = await doctors
          .where('department', isEqualTo: selectedDepartment)
          .get();

      for (var doc in query.docs) {
        await doc.reference.update({'avatarColor': color.toARGB32()});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${selectedDepartment!} colors updated successfully"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  Widget buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedDepartment, // ✅ بدل initialValue
      decoration: InputDecoration(
        labelText: "Choose Department",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: departmentColors.keys.map((dept) {
        return DropdownMenuItem<String>(
          value: dept,
          child: Row(
            children: [
              CircleAvatar(radius: 8, backgroundColor: departmentColors[dept]),
              const SizedBox(width: 10),
              Text(dept),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedDepartment = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color previewColor = selectedDepartment == null
        ? Colors.grey
        : departmentColors[selectedDepartment]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Avatar Colors"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildDepartmentDropdown(),
            const SizedBox(height: 30),

            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: previewColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    color: previewColor.withValues(alpha: 0.4),
                  ),
                ],
              ),
              child: const Icon(Icons.person, size: 55, color: Colors.white),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading || selectedDepartment == null
                    ? null
                    : updateColor,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Update Avatar Color",
                        style: TextStyle(fontSize: 17),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
