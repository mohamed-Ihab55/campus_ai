import 'package:campus_ai/core/helper/custom_text_form_field.dart';
import 'package:campus_ai/core/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/doctors_dashboard_model.dart';
import '../../data/cubits/doctors_cubit/doctors_dashboard_cubit.dart';

class EditDoctorScreen extends StatefulWidget {
  final DoctorsDashboardModel doctor;

  const EditDoctorScreen({super.key, required this.doctor});

  @override
  State<EditDoctorScreen> createState() => _EditDoctorScreenState();
}

class _EditDoctorScreenState extends State<EditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController titleController;
  late final TextEditingController roomController;
  late final TextEditingController initialsController;

  String? department;
  bool isLoading = false;

  final List<String> departments = const [
    "CS",
    "Mathematics",
    "Statistics",
    "Physics",
    "Chemistry",
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.doctor.name);
    titleController = TextEditingController(text: widget.doctor.title);
    roomController = TextEditingController(text: widget.doctor.room);
    initialsController = TextEditingController(text: widget.doctor.initials);

    department = widget.doctor.department;
  }

  Future<void> updateDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final updated = DoctorsDashboardModel(
      id: widget.doctor.id,
      name: nameController.text.trim(),
      title: titleController.text.trim(),
      room: roomController.text.trim(),
      initials: initialsController.text.trim(),
      department: department!,
      avatarColor: widget.doctor.avatarColor,
    );

    await context.read<DoctorsDashboardCubit>().updateDoctor(updated);

    setState(() => isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Doctor updated",
            style: TextStyle(color: AppColors.surface),
          ),
          backgroundColor: AppColors.green,
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
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// AVATAR
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initialsController.text,
                    style: TextStyle(color: AppColors.surface),
                  ),
                ),

                const SizedBox(height: 20),

                CustomTextFormField(
                  labelText: 'Name',
                  controller: nameController,
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  labelText: 'Title',
                  controller: titleController,
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  labelText: 'Room',
                  controller: roomController,
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  labelText: 'Initials',
                  controller: initialsController,
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  style: TextStyle(color: AppColors.textPrimary,fontSize: 15),
                  dropdownColor: AppColors.surface,
                  initialValue: department,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Departments',
                    labelStyle: TextStyle(color: AppColors.primary),
                    hintStyle: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  items: departments
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => department = value);
                  },
                  validator: (v) => v == null ? "Select department" : null,
                ),

                const SizedBox(height: 20),

                CustomButton(
                  text: 'Save Changes',
                  backgroundColor: AppColors.primary,
                  onTap: isLoading ? null : updateDoctor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
