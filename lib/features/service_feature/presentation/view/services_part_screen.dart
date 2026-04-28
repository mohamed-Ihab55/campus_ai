import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/service_feature/data/cubit/services_cubit.dart';
import 'package:campus_ai/features/service_feature/data/model/service_item.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicesTab extends StatelessWidget {
  final List<ServiceItem> services;
  const ServicesTab({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServicesCubit()..getServices(),
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            if (state is ServicesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDeep),
              );
            }

            if (state is ServicesError) {
              return Center(child: Text(state.message));
            }

            if (state is ServicesSuccess) {
              return ServicesGrid(services: state.services);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
