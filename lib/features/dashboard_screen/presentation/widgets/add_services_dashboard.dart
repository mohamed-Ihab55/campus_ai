import 'package:campus_ai/core/helper/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/custom_button.dart';
import '../../data/cubits/services_cubit/services_dashboard_cuibt.dart';

class AddServicesDashboard extends StatefulWidget {
  const AddServicesDashboard({super.key});

  @override
  State<AddServicesDashboard> createState() =>
      _AddServicesDashboardState();
}

class _AddServicesDashboardState
    extends State<AddServicesDashboard> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final subTitleController = TextEditingController();
  final iconController = TextEditingController();
  final routeController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    subTitleController.dispose();
    iconController.dispose();
    routeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ServiceDashboardCubit>().addService(
      icon: iconController.text.trim(),
      title: titleController.text.trim(),
      subTitle: subTitleController.text.trim(),
      route: routeController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceDashboardCubit, ServiceDashboardState>(
      listener: (context, state) {
        if (state is ServiceSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.green,
              content: Text(
                "Service added successfully",
                style: TextStyle(color: AppColors.surface),
              ),
            ),
          );
          Navigator.pop(context);
        }

        if (state is ServiceError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [


                CustomTextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                  labelText: 'Title',controller: titleController,hintText: 'Title',),
                const SizedBox(height: 15,),
                CustomTextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'SubTitle is required';
                    }
                    return null;
                  },
                  labelText: 'SubTitle',controller: subTitleController,hintText: 'SubTitle',),
                const SizedBox(height: 15),

                BlocBuilder<ServiceDashboardCubit, ServiceDashboardState>(
                  builder: (context,state) {
                    final loading = state is ServiceLoading;
                    return CustomButton(
                      text: 'Add Service',
                      backgroundColor: AppColors.primary,
                      onTap: loading
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          _submit();
                        }
                      },
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
