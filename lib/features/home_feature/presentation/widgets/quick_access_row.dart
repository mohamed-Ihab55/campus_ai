import 'package:campus_ai/features/home_feature/data/cubit/quick_cubit.dart';
import 'package:campus_ai/features/home_feature/data/cubit/quick_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'quick_card.dart';

class QuickAccessRow extends StatelessWidget {
  const QuickAccessRow({super.key});

  IconData _mapIcon(String icon) {
    switch (icon) {
      case 'doctor':
        return Icons.person;
      case 'globe':
        return Icons.public;
      case 'computer':
        return Icons.computer;
      case 'apartment':
        return Icons.apartment;
      case 'calculate':
        return Icons.calculate;
      case 'newspaper':
        return Icons.newspaper;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuickCubit, QuickState>(
      builder: (context, state) {
        if (state is QuickLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is QuickError) {
          return Center(child: Text(state.msg));
        }

        final items = (state as QuickLoaded).items;

        return SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final item = items[i];

              return QuickCard(
                icon: _mapIcon(item.icon),
                label: item.label,
                bgColor: Color(item.bgColor),
                borderColor: Color(item.borderColor),
                onTap: () {
                  Navigator.pushNamed(context, item.route);
                },
              );
            },
          ),
        );
      },
    );
  }
}
