import 'package:flutter/material.dart';
import 'package:campus_ai/features/service_feature/data/model/service_item.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/service_card.dart';

class ServicesGrid extends StatelessWidget {
  final List<ServiceItem> services;

  const ServicesGrid({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        double maxCrossAxisExtent;
        double childAspectRatio;

        if (width < 360) {
          maxCrossAxisExtent = width;
          childAspectRatio = 2.2;
        } else if (width < 600) {
          maxCrossAxisExtent = width / 2;
          childAspectRatio = 1.1;
        } else if (width < 900) {
          maxCrossAxisExtent = width / 3;
          childAspectRatio = 1.15;
        } else if (width < 1200) {
          maxCrossAxisExtent = width / 4;
          childAspectRatio = 1.2;
        } else {
          maxCrossAxisExtent = width / 5;
          childAspectRatio = 1.2;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              // child: FeatureLabel(label: 'ACADEMIC SERVICES'),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: services.length,

                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),

                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: ServiceCard(item: services[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
