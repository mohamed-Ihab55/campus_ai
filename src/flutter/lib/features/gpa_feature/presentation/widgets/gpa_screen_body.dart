import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/gpa_feature/data/cubit/gpa_cubit.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/cumulative_tab.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/semester_tab.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GpaScreenBody extends StatefulWidget {
  const GpaScreenBody({super.key});

  @override
  State<GpaScreenBody> createState() => _GpaScreenBodyState();
}

class _GpaScreenBodyState extends State<GpaScreenBody>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,

        body: Column(
          children: [

            ServicesHeader(
              height: 270,
              titleName: 'Grade Point Average',
              subTitle: 'Calculator',
              description: 'Faculty of Science - Ain Shams University',
            ),

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
                  Tab(text: 'Semester'),
                  Tab(text: 'Cumulative'),
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<GpaCubit, GpaState>(
                builder: (context, state) {
                  final cubit = context.read<GpaCubit>();

                  return TabBarView(
                    children: [

                      SemesterTab(
                        courses: state.courses,
                        result: state.semesterResult,
                        onAdd: cubit.addCourse,
                        onRemove: cubit.removeCourse,
                        onCourseChanged: cubit.updateCourse,
                        onCalculate: cubit.calcSemester,
                        onReset: cubit.resetSemester,
                      ),

                      CumulativeTab(
                        semesters: state.semesters,
                        result: state.cumulativeResult,
                        onAdd: cubit.addSemester,
                        onRemove: cubit.removeSemester,
                        onSemesterChanged: cubit.updateSemester,
                        onCalculate: cubit.calcCumulative,
                        onReset: cubit.resetCumulative,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}