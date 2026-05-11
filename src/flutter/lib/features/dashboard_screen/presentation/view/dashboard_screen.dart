import 'package:campus_ai/features/authentication_feature/presentation/view/login_screen.dart';
import 'package:campus_ai/features/dashboard_screen/presentation/view/main_dashboard.dart';
import 'package:campus_ai/features/service_feature/presentation/widgets/services_header.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              ServicesHeader(
                titleName: 'Admin',
                subTitle: 'Dashboard',
                description: 'Control in everything in one place',
                height: 235,
              ),
              Expanded(child: AdminDashboard()),
            ],
          ),

          Positioned(
            top: 55,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                final selected = await showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(100, 80, 20, 0),
                  items: const [
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                );

                if (selected == 'logout') {
                  await FirebaseAuth.instance.signOut();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },

              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
