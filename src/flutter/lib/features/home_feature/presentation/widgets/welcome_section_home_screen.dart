import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomeSectionHomeScreen extends StatelessWidget {
  const WelcomeSectionHomeScreen({
    super.key,
    required this.tileName,
    required this.subTitle,
    required this.description,
  });

  final String tileName;
  final String subTitle;
  final String description;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? "Admin";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, $userName to',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),

        const SizedBox(height: 3),

        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
            children: [
              TextSpan(text: '$tileName\n'),
              TextSpan(
                text: subTitle,
                style: const TextStyle(
                  color: Color(0xFF93C5FD),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}