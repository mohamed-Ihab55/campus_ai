import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/service_tab_bar.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_header.dart';
import 'package:flutter/material.dart';

class ServicesAppBar extends StatelessWidget {
  final TabController tabController;
  final bool forceElevated;
  final String tab1, tab2, titleName, subTitle, description;
  const ServicesAppBar({
    super.key,
    required this.tabController,
    required this.forceElevated,
    required this.tab1,
    required this.tab2,
    required this.titleName,
    required this.subTitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      floating: true,
      snap: true,
      forceElevated: forceElevated,
      backgroundColor: AppColors.primaryDark,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: ServicesHeader(
          titleName: titleName,
          subTitle: subTitle,
          description: description,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: ServiceTabBar(controller: tabController, tab1: tab1, tab2: tab2),
      ),
    );
  }
}
