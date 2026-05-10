import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/service_feature/data/cubit/services_cubit.dart';
import 'package:campus_ai/features/service_feature/data/model/faq_item.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/faq_part_screen.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helper/grid_loading_case.dart';
import '../widgets/services_grid.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});
  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen>
    with SingleTickerProviderStateMixin {
  final List<FaqItem> _faqs = [
    FaqItem(
      question: 'How do I register for courses?',
      answer:
          'Course registration is done through the student portal or at the student affairs office in Building A — first floor — office 110. Working hours from 8 AM to 3 PM.',
    ),
    FaqItem(
      question: 'Where is the academic affairs office?',
      answer:
          'The academic affairs office is located in Building A, first floor, office 110. You can visit during working hours from 8 AM to 3 PM or contact them at 02-2456-7890.',
      isOpen: true,
    ),
    FaqItem(
      question: 'How do I request an enrollment certificate or transcript?',
      answer:
          'You can request it from the Student Affairs Office in Building A or through the electronic portal. The processing time is 3 to 5 business days. The fee is 10 EGP per certificate.',
    ),
    FaqItem(
      question: 'What is the allowed absence rate?',
      answer:
          'The maximum allowed absence rate is 25% of the total class hours. Exceeding this rate will result in disqualification from the exam.',
    ),
    FaqItem(
      question: 'How do I pay the tuition fees?',
      answer:
          'Tuition fees are paid at the beginning of each academic term through approved banks or at the treasury office in Building A — ground floor. Keep your payment receipt.',
    ),
  ];
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
              titleName: 'Services',
              subTitle: 'Affairs',
              description: 'All services in one place',
            ),
            Container(
              margin: const EdgeInsets.only(left: 16,right: 16,top: 16),
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
                  Tab(text: 'Services'),
                  Tab(text: 'FAQ'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                  children: [
                    BlocProvider(
                      create: (_) => ServicesCubit()..getServices(),
                      child: BlocBuilder<ServicesCubit, ServicesState>(
                        builder: (context, state) {
                          if (state is ServicesLoading) {
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: 6,
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.78,
                              ),
                              itemBuilder: (_, index) {
                                return const GridLoadingCase();
                              },
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

                    FaqPartScreen(
                      faqs: _faqs,
                      onToggle: (i) {
                        setState(() => _faqs[i].isOpen = !_faqs[i].isOpen);
                      },
                    ),
                  ],
                ),
            ),
          ]
        ),
      ),
    );
  }
}
