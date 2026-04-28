import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/feature_label.dart';
import 'package:campus_ai/features/service_feature/data/cubit/services_cubit.dart';
import 'package:campus_ai/features/service_feature/data/model/service_item.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/service_card.dart';
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
        backgroundColor: AppColors.surface2,
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

class ServicesGrid extends StatelessWidget {
  final List<ServiceItem> services;

  const ServicesGrid({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 18),
        Row(children: [FeatureLabel(label: 'ACADEMIC SERVICES')]),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              return ServiceCard(item: services[index]);
            },
          ),
        ),
      ],
    );
  }
}
