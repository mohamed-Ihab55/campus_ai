import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helper/custom_text_form_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/custom_button.dart';
import '../../data/doctors_cubit/doctors_dashboard_cubit.dart';
import '../../data/models/doctors_dashboard_model.dart';

class AddDoctorForm extends StatefulWidget {
  const AddDoctorForm({super.key});

  @override
  State<AddDoctorForm> createState() => _AddDoctorFormState();
}

class _AddDoctorFormState extends State<AddDoctorForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController initialsController = TextEditingController();

  String? selectedDepartment;
  int? selectedColor;

  bool isLoading = false;

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

  Widget departmentDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        dropdownColor: AppColors.surface,
        initialValue: selectedDepartment,
        validator: (value) {
          if (value == null) {
            return "Choose Department";
          }
          return null;
        },
        decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelText: 'Departments',
            labelStyle: TextStyle(color: AppColors.primary),
            hintText: 'Select departments',
            hintStyle: TextStyle(color: AppColors.textPrimary.withValues(alpha: 0.5),fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary),
            )
        ),
        items: departments.map((dept) {
          return DropdownMenuItem(
            value: dept,
            child: Text(
              dept,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedDepartment = value;
            selectedColor = avatarColors[value]?.toARGB32();
          });
        },
      ),
    );
  }

  Widget colorDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        dropdownColor: AppColors.surface,
        initialValue: selectedColor,
        validator: (value) {
          if (value == null) {
            return "Choose Color";
          }
          return null;
        },
        decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelText: 'Avatar Color',
            labelStyle: TextStyle(color: AppColors.primary),
            hintText: 'Select avatar color',
            hintStyle: TextStyle(color: AppColors.textPrimary.withValues(alpha: 0.5),fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary),
            )
        ),
        items: avatarColors.entries.map((entry) {
          return DropdownMenuItem<int>(
            value: entry.value.toARGB32(),
            child: Row(
              children: [
                CircleAvatar(radius: 8, backgroundColor: entry.value),
                const SizedBox(width: 12),
                Text(
                  entry.key,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedColor = value;
          });
        },
      ),
    );
  }

  Future<void> addDoctor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final doctor = DoctorsDashboardModel(
      id: '',
      name: nameController.text.trim(),
      department: selectedDepartment!,
      initials: initialsController.text.trim(),
      room: roomController.text.trim(),
      title: titleController.text.trim(),
      avatarColor: selectedColor!,
    );

    await context.read<DoctorsDashboardCubit>().addDoctor(doctor);

    setState(() {
      isLoading = false;
    });

    nameController.clear();
    titleController.clear();
    roomController.clear();
    initialsController.clear();

    setState(() {
      selectedDepartment = null;
      selectedColor = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.green,
          content: Text("Doctor Added Successfully"),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    titleController.dispose();
    roomController.dispose();
    initialsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          CustomTextFormField(
            hintText: 'Doctor Name',
            labelText: 'Doctor Name',
            controller: nameController,
          ),
          const SizedBox(height: 15,),
          CustomTextFormField(
            hintText: 'Professor',
            labelText: 'Doctor Title',
            controller: titleController,
          ),
          const SizedBox(height: 15,),
          CustomTextFormField(
            hintText: 'Doctor Room',
            labelText: 'Room',
            controller: roomController,
          ),
          const SizedBox(height: 15,),
          CustomTextFormField(
            hintText: 'Shortcut doctor name',
            labelText: 'Doctor Initials',
            controller: initialsController,
          ),
          const SizedBox(height: 15,),

          departmentDropdown(),

          colorDropdown(),

          const SizedBox(height: 20),

          CustomButton(
            text: 'Add Doctor',
            backgroundColor: AppColors.primary,
            onTap: isLoading ? null : addDoctor,
          ),
        ],
      ),
    );
  }
}
