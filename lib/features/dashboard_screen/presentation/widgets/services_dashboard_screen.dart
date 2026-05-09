import 'package:campus_ai/features/dashboard_screen/presentation/widgets/add_services_dashboard.dart';
import 'package:campus_ai/features/service_feature/presentation/view/services_part_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../service_feature/data/cubit/services_cubit.dart';
import '../../data/cubits/services_cubit/services_dashboard_cuibt.dart';

class ServicesDashboardScreen extends StatelessWidget {
  const ServicesDashboardScreen({super.key});

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
                    Tab(text: 'Add Services'),
                    Tab(text: 'Services List'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    BlocProvider(
                      create: (_) => ServiceDashboardCubit(),
                      child: const AddServicesDashboard(),
                    ),
                    BlocProvider(
                      create: (_) => ServicesCubit()..getServices(),
                      child: BlocBuilder<ServicesCubit, ServicesState>(
                        builder: (context, state) {
                          if (state is ServicesLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (state is ServicesError) {
                            return Center(child: Text(state.message));
                          }

                          if (state is ServicesSuccess) {
                            return ServicesTab(services: state.services);
                          }

                          return const SizedBox();
                        },
                      ),
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
