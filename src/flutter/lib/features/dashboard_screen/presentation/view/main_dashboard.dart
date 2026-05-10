import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../widgets/departments_dashboard_screen.dart';
import '../widgets/doctors_dash_board_screen.dart';
import '../widgets/labs_dashboard_screen.dart';
import '../widgets/services_dashboard_screen.dart';
import '../widgets/users_dashboard_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  int _index = 0;

  final List<Widget> _screens = const [
    DoctorsDashboardScreen(),
    ServicesDashboardScreen(),
    LabsDashboardScreen(),
    DepartmentsDashboardScreen(),
    UsersDashboardScreen(),
  ];

  final List<_NavItem> _items = const [
    _NavItem(Icons.person_outline_rounded, "Doctors"),
    _NavItem(Icons.miscellaneous_services_rounded, "Services"),
    _NavItem(Icons.science_outlined, "Labs"),
    _NavItem(Icons.apartment_rounded, "Departments"),
    _NavItem(Icons.people_alt_outlined, "Users"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,

      /// BODY ANIMATION
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey(_index),
          child: _screens[_index],
        ),
      ),

      /// CUSTOM PROFESSIONAL NAVIGATION BAR
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
                  (index) {
                final isSelected = _index == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _index = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutExpo,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 18 : 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: isSelected
                          ? LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.7),
                        ],
                      )
                          : null,
                    ),
                    child: Row(
                      children: [
                        AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          scale: isSelected ? 1.15 : 1,
                          child: Icon(
                            _items[index].icon,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 24,
                          ),
                        ),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: isSelected
                              ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              _items[index].label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}