import 'package:campus_ai/features/authentication_feature/data/cubit/auth_cubit.dart';
import 'package:campus_ai/features/authentication_feature/presentation/widgets/login_screen_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(create: (_) => AuthCubit(),
      child: const LoginScreenBody(),
      ),
    );
  }
}
