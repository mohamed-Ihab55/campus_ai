import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/gpa_feature/data/cubit/gpa_cubit.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/cumulative_tab.dart';
import 'package:campus_ai/features/gpa_feature/presentation/widgets/semester_tab.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GpaScreenBody extends StatefulWidget {
  const GpaScreenBody({super.key});

  @override
  State<GpaScreenBody> createState() => _GpaScreenBodyState();
}

class _GpaScreenBodyState extends State<GpaScreenBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          ServicesAppBar(
            tabController: _tabCtrl,
            forceElevated: innerBoxIsScrolled,
            tab1: 'Semester',
            tab2: 'Cumulative',
            titleName: 'Grade Point Average',
            subTitle: 'Calculator',
            description: 'Faculty of Science - Ain Shams University',
          ),
        ],
        body: BlocBuilder<GpaCubit, GpaState>(
          builder: (context, state) {
            final cubit = context.read<GpaCubit>();

            return TabBarView(
              controller: _tabCtrl,
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
    );
  }
}
