import 'package:campus_ai/features/dashboard_screen/data/cubits/add_lab_cubit/add_lab_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helper/custom_text_form_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/custom_button.dart';

class AddLabScreen extends StatefulWidget {
  const AddLabScreen({super.key});

  @override
  State<AddLabScreen> createState() => _AddLabScreenState();
}

class _AddLabScreenState extends State<AddLabScreen> {
  final TextEditingController labNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    labNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LabsDashboardCubit, LabsDashboardState>(
      listener: (context, state) {
        if (state is LabsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lab Added Successfully'),
            ),
          );
          labNameController.clear();
        }

        if (state is LabsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextFormField(
                  controller: labNameController,
                  hintText: 'Enter Lab Name',
                  labelText: 'Lab Name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lab name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                CustomButton(
                  text: 'Add Lab',
                  backgroundColor: AppColors.primary,
                  onTap: state is LabsLoading
                      ? null
                      : () {
                    if (formKey.currentState!.validate()) {
                      context
                          .read<LabsDashboardCubit>()
                          .addLab(labNameController.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}