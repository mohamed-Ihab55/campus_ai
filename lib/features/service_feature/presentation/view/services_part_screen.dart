
import 'package:campus_ai/features/home_feature/presentation/widgets/feature_label.dart';
import 'package:campus_ai/features/service_feature/data/model/service_item.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/service_card.dart';
import 'package:flutter/material.dart';

class ServicesTab extends StatelessWidget {
  final List<ServiceItem> services;
  const ServicesTab({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 20,
          ),
        ),
        // section label
        const SliverToBoxAdapter(
          child: FeatureLabel(label: 'Academical Services'),
        ),

        // 2-column grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => ServiceCard(
                item: services[i],
              ),
              childCount: services.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
