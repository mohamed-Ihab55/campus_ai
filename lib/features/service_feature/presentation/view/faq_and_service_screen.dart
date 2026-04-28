import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/features/service_feature/data/cubit/services_cubit.dart';
import 'package:campus_ai/features/service_feature/data/model/faq_item.dart';
import 'package:campus_ai/features/service_feature/presentation/view/faq_part_screen.dart';
import 'package:campus_ai/features/service_feature/presentation/view/services_part_screen.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});
  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
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
      backgroundColor: AppColors.surface2,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          ServicesAppBar(
            tabController: _tabCtrl,
            forceElevated: innerBoxIsScrolled,
            tab1: 'Services',
            tab2: 'FAQ',
            titleName: 'Services',
            subTitle: 'Affairs',
            description: 'Every service you need in one place',
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
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

            FaqPartScreen(
              faqs: _faqs,
              onToggle: (i) {
                setState(() => _faqs[i].isOpen = !_faqs[i].isOpen);
              },
            ),
          ],
        ),
      ),
    );
  }
}
