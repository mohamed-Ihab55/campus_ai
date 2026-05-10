import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/departments_feature/data/cubit/department_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepartmentsScreenBody extends StatelessWidget {
  const DepartmentsScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: BlocBuilder<DepartmentCubit, DepartmentState>(
        builder: (context, state) {
          if (state is DepartmentLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryDeep),
            );
          }
          if (state is DepartmentError) {
            return Center(child: Text(state.message));
          }
          if (state is DepartmentSuccess) {
            if (state.departments.isEmpty) {
              return const Center(
                child: Text(
                  "No Departments Found",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }
            return Column(
              children: [

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.departments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final dept = state.departments[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ExpansionTile(
                          collapsedIconColor: AppColors.primaryDeep,
                          iconColor: AppColors.primary,
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          leading: Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDeep,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                dept.deptName.isNotEmpty
                                    ? dept.deptName[0]
                                    : "?",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            dept.deptName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          subtitle: Text(
                            "${dept.subFields.length} Specialties",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                          children: dept.subFields.map((item) {
                            return ListTile(
                              leading: const Icon(
                                Icons.arrow_right,
                                color: AppColors.primary,
                              ),
                              title: Text(item),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
