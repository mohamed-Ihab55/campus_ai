import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/feature_label.dart';
import 'package:campus_ai/core/helper/search_text_field.dart';
import 'package:campus_ai/features/service_feature/data/model/faq_item.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/faq_card.dart';
import 'package:flutter/material.dart';

class FaqPartScreen extends StatelessWidget {
  final List<FaqItem> faqs;
  final void Function(int) onToggle;
  const FaqPartScreen({super.key, required this.faqs, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: SearchTextField(
              textColor: AppColors.primaryDark,
              cursorColor: AppColors.primaryDark,
              fillColor: AppColors.surface,
              hintText: 'Search for some questions...',
              iconAndTextColor: AppColors.primary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primaryDark,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: FeatureLabel(label: 'Common Questions'),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => FaqCard(item: faqs[i], onTap: () => onToggle(i)),
            childCount: faqs.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
