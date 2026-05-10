import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../authentication_feature/data/cubit/auth_cubit.dart';

String getSeason() {
  final month = DateTime.now().month;

  if (month >= 3 && month <= 5) return 'Spring';
  if (month >= 6 && month <= 8) return 'Summer';
  if (month >= 9 && month <= 11) return 'Autumn';
  return 'Winter';
}

class CustomHomeAppBar extends StatelessWidget {
  const CustomHomeAppBar({super.key, required this.blinkAnim});

  final Animation<double> blinkAnim;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // semester badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: blinkAnim,
                builder: (_, _) => Opacity(
                  opacity: blinkAnim.value,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${getSeason()} ${DateTime.now().year}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: BlocBuilder<AuthCubit,AuthState>(
            builder: (context,state ) {
              return GestureDetector(
                onTap: () async {
                  final selected = await showMenu(
                    context: context,
                    position: const RelativeRect.fromLTRB(100, 80, 20, 0),
                    items: const [
                      PopupMenuItem(
                        textStyle: TextStyle(color: AppColors.textSecondary,fontSize: 14),
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red,size: 15,),
                            SizedBox(width: 10),
                            Text('Logout',style: TextStyle(color: AppColors.textSecondary,fontSize: 14),),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (selected == 'logout') {
                    await context.read<AuthCubit>().logout();


                    if (!context.mounted) return;

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  }
                },
                child: Icon(Icons.keyboard_arrow_down, color: AppColors.surface),
              );
            }
          ),
        ),
      ],
    );
  }
}
