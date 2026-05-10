import 'package:campus_ai/core/helper/custom_text_form_field.dart';
import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/core/utils/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final TextEditingController emailController =
  TextEditingController();

  final GlobalKey<FormState> formKey =
  GlobalKey<FormState>();

  bool isLoading = false;
  bool isEmailSent = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    try {
      setState(() {
        isLoading = true;
      });

      final email = emailController.text.trim();

      print("RESET EMAIL => $email");

      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);

      if (!mounted) return;

      setState(() {
        isEmailSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent successfully',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print("FIREBASE ERROR => ${e.code}");
      print("MESSAGE => ${e.message}");

      String errorMessage = 'Something went wrong';

      switch (e.code) {
        case 'user-not-found':
          errorMessage =
          'No user found for this email';
          break;

        case 'invalid-email':
          errorMessage =
          'Invalid email address';
          break;

        case 'network-request-failed':
          errorMessage =
          'Check your internet connection';
          break;

        case 'too-many-requests':
          errorMessage =
          'Too many requests, try again later';
          break;

        default:
          errorMessage =
              e.message ?? 'Authentication error';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(errorMessage),
        ),
      );
    } catch (e) {
      print("GENERAL ERROR => $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              AnimatedSwitcher(
                duration:
                const Duration(milliseconds: 400),
                child: isEmailSent
                    ? _SuccessWidget(
                  email:
                  emailController.text.trim(),
                )
                    : _ForgotPasswordForm(
                  formKey: formKey,
                  emailController:
                  emailController,
                  isLoading: isLoading,
                  onSubmit: resetPassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _ForgotPasswordForm({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(alpha: 0.1),
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppColors.primary,
              size: 35,
            ),
          ),

          const SizedBox(height: 25),

          Text(
            'Forgot Password?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Enter your email address and we will send you a password reset link.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 35),

          CustomTextFormField(
            prefixIcon:
            const Icon(Icons.email_outlined),
            labelText: 'Email Address',
            hintText: 'student@gmail.com',
            controller: emailController,
            keyboardType:
            TextInputType.emailAddress,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Email is required';
              }

              final emailRegex = RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              );

              if (!emailRegex
                  .hasMatch(value.trim())) {
                return 'Enter a valid email';
              }

              return null;
            },
          ),

          const SizedBox(height: 30),

          CustomButton(
            text: isLoading
                ? 'Sending...'
                : 'Send Reset Link',
            backgroundColor:
            AppColors.primary,
            onTap:
            isLoading ? null : onSubmit,
          ),

          const SizedBox(height: 18),

          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Back to Login',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  final String email;

  const _SuccessWidget({
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color:
            Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: Colors.green,
            size: 45,
          ),
        ),

        const SizedBox(height: 25),

        Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'We have sent a password reset link to:',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          email,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 35),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
            label: const Text(
              'Back to Login',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}