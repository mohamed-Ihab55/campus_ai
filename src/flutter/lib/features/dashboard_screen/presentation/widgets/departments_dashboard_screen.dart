import 'package:campus_ai/core/helper/custom_text_form_field.dart';
import 'package:campus_ai/core/utils/custom_button.dart';
import 'package:campus_ai/features/departments_feature/presentation/widgets/departments_screen_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../departments_feature/data/cubit/department_cubit.dart';
import '../../data/cubits/add_department_cubit/add_department_cubit.dart';

class DepartmentsDashboardScreen extends StatelessWidget {
  const DepartmentsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TabBar(
                dividerColor: AppColors.primary,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).primaryColor,
                ),
                labelColor: AppColors.surface,
                unselectedLabelColor: AppColors.textTertiary,
                tabs: const [
                  Tab(text: 'Add Department'),
                  Tab(text: 'Departments List'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const AddDepartmentScreen(),
                  BlocProvider(
                    create: (_) => DepartmentCubit()..getDepartments(),
                    child: const DepartmentsScreenBody(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddDepartmentScreen extends StatefulWidget {
  const AddDepartmentScreen({super.key});

  @override
  State<AddDepartmentScreen> createState() => _AddDepartmentScreenState();
}

class _AddDepartmentScreenState extends State<AddDepartmentScreen> {
  final TextEditingController deptController = TextEditingController();

  final TextEditingController subFieldController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<String> subFields = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddDepartmentCubit(),
      child: BlocConsumer<AddDepartmentCubit, AddDepartmentState>(
        listener: (context, state) {
          if (state is AddDepartmentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppColors.green,
                content: Text(
                  'Department Added Successfully',
                  style: TextStyle(color: AppColors.surface),
                ),
              ),
            );

            deptController.clear();
            subFieldController.clear();

            setState(() {
              subFields.clear();
            });
          }

          if (state is AddDepartmentError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          final cubit = AddDepartmentCubit.get(context);

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: deptController,
                      labelText: 'Department Name',
                      hintText: 'Department name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Department Name';
                        }
                        return null;
                      },
                    ),


                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            hintText: 'Department subFields',
                            labelText: 'SubFields',
                            controller: subFieldController,
                          ),
                        ),

                        const SizedBox(width: 10),


                        Expanded(
                          child: CustomButton(
                            text: 'Add', backgroundColor: AppColors.primary,onTap: () {
                            if (subFieldController.text.trim().isNotEmpty) {
                              setState(() {
                                subFields.add(subFieldController.text.trim());
                              });

                              subFieldController.clear();
                            }
                          },),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    state is AddDepartmentLoading
                        ? const CircularProgressIndicator()
                        : CustomButton(text: 'Add Department', backgroundColor: AppColors.primary,onTap:() {
                      if (formKey.currentState!.validate()) {
                        cubit.addDepartment(
                          deptName: deptController.text.trim(),
                          subFields: subFields,
                        );
                      }
                    } ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
