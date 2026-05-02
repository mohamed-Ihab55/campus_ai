import 'package:flutter/material.dart';



String getSeason() {
  final month = DateTime.now().month;

  if (month >= 3 && month <= 5) return 'Spring';
  if (month >= 6 && month <= 8) return 'Summer';
  if (month >= 9 && month <= 11) return 'Autumn';
  return 'Winter';
}

String getCurrentSeason() {
  final month = DateTime.now().month;

  if (month >= 3 && month <= 5) {
    return "Spring";
  } else if (month >= 6 && month <= 8) {
    return "Summer";
  } else if (month >= 9 && month <= 11) {
    return "Autumn";
  } else {
    return "Winter";
  }
}

String getSeasonWithYear() {
  final now = DateTime.now();
  final season = getCurrentSeason();
  return "$season ${now.year}";
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
<<<<<<< HEAD
                '${getSeason()} ${DateTime.now().year}',
=======
                getSeasonWithYear(),
>>>>>>> 8014cf8ebaa47dd7b05ada3bf76e90356e27fc31
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
<<<<<<< HEAD
=======

        // notification button
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: GestureDetector(
                onTap: () {
                  // context.read<ThemeProvider>().toggleTheme();
                },
                child: Icon(
                  context.watch<ThemeProvider>().isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode_outlined,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
>>>>>>> 8014cf8ebaa47dd7b05ada3bf76e90356e27fc31
      ],
    );
  }
}
