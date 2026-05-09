import 'dart:async';

import 'package:campus_ai/core/theme/app_colors.dart';
import 'package:campus_ai/core/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/helper/custom_text_form_field.dart';
import '../../../../core/utils/social_button.dart';
import '../../data/cubit/auth_cubit.dart';

class LoginScreenBody extends StatefulWidget {
  const LoginScreenBody({super.key});

  @override
  State<LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<LoginScreenBody>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _autoValidate = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  String _animatedText = "";
  int _textIndex = 0;

  final String _fullText =
      "Your Smart AI Campus Assistant\nAsk. Learn. Succeed.";

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (_textIndex < _fullText.length) {
        setState(() {
          _animatedText += _fullText[_textIndex];
          _textIndex++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.red,
                  content: Text(state.message),
                ),
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Form(
                          key: formKey,
                          autovalidateMode: _autoValidate
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 10),

                              Hero(
                                tag: "logo",
                                child: Image.asset(
                                  'assets/images/icon_splash.png',
                                  width: 90,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                _animatedText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 25),

                              CustomTextFormField(
                                hintText: 'abc@gmail.com',
                                labelText: 'Email',
                                prefixIcon: Icon(
                                  Icons.mail_outline,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                controller: emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your email';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              CustomTextFormField(
                                obscureText: _obscurePassword,
                                hintText: '***********',
                                labelText: 'Password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                controller: passwordController,
                                validator: (value) {
                                  if (value == null || value.length < 6) {
                                    return 'Enter your password';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 25),

                              CustomButton(
                                text: 'Login',
                                backgroundColor: AppColors.primary,
                                textColor: AppColors.surface,
                                onTap: state is AuthLoading
                                    ? null
                                    : () {
                                  setState(() {
                                    _autoValidate = true;
                                  });

                                  final isValid = formKey.currentState!.validate();

                                  if (!isValid) return;

                                  context.read<AuthCubit>().login(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/main_screen',
                                        (route) => false,
                                  );
                                },
                              ),

                              const SizedBox(height: 10),

                              SocialButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                  context
                                      .read<AuthCubit>()
                                      .signInWithGoogle();
                                },
                                text: 'Continue with Google',
                                icon: FontAwesomeIcons.google,
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/register_screen',
                                  );
                                },
                                child: Text(
                                  "Don't have an account? Create account",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextButton(onPressed: (){Navigator.pushNamed(context, '/dashboard');}, child: Text('dashboard'))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}