import 'package:campus_ai/features/dashboard_screen/presentation/view/main_dashboard.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_header.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ServicesHeader(
            titleName: 'Admin',
            subTitle: 'Dashboard',
            description: 'Control in everything in one place',
            height: 235,
          ),

          Expanded(
            child: AdminDashboard(),
          ),
        ],
      ),
    );
  }
}