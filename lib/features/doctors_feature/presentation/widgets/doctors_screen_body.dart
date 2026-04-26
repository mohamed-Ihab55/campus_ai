import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/doctors_feature/data/cubit/doctor_cubit.dart';
import 'package:campus_ai/features/doctors_feature/data/cubit/doctor_state.dart';
import 'package:campus_ai/features/doctors_feature/presentation/widgets/doctor_card.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/search_text_field.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorsScreenBody extends StatelessWidget {
  const DoctorsScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface2,
      body: BlocBuilder<DoctorsCubit, DoctorsState>(
        builder: (context, state) {
          if (state is DoctorsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DoctorsError) {
            return Center(child: Text(state.message));
          }

          if (state is DoctorsLoaded) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ServicesHeader(
                    height: 240,
                    titleName: 'Faculty',
                    subTitle: 'Member',
                    description:
                        'Explore our esteemed faculty members and their rooms.',
                  ),
                ),
                SliverToBoxAdapter(
                  child: SearchTextField(
                    cursorColor: AppColors.primary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    fillColor: Colors.transparent,
                    iconAndTextColor: Colors.black,
                    hintText: 'Search doctor..',
                    textColor: AppColors.primary,
                    onChanged: (v) => context.read<DoctorsCubit>().search(v),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.departments.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final dept = state.departments[i];
                        final active = dept == state.selectedDept;

                        return GestureDetector(
                          onTap: () => context
                              .read<DoctorsCubit>()
                              .selectDepartment(dept),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: active
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryDeep,
                                      ],
                                    )
                                  : null,
                              color: active ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: active
                                    ? Colors.transparent
                                    : AppColors.primary.withValues(alpha: 0.5),
                              ),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF3B82F6,
                                        ).withValues(alpha: 0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// Optional dot indicator
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? Colors.white
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  dept,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: active
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 15)),
                state.filtered.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'No doctors found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final d = state.filtered[i];
                          return Column(
                            children: [
                              SizedBox(height: 2),
                              DoctorCard(doctor: d),
                            ],
                          );
                        }, childCount: state.filtered.length),
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
