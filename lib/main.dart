import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/screens/customer/customer_register_page.dart';
import 'package:herafy/features/auth/screens/login.dart';
import 'package:herafy/features/auth/screens/role_selection.dart';
import 'package:herafy/features/auth/screens/services_provider/provider_register_page.dart';
import 'package:herafy/features/auth/screens/waiting_approve_page.dart';

void main() {
  runApp(BlocProvider(create :(context) => AuthCubit(),
  child: const HerafyApp()));
}

class HerafyApp extends StatelessWidget {
  const HerafyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      routes: {
        RoleSelectionPage.routeName: (context) => const RoleSelectionPage(),
        LoginPage.routeName: (context) => const LoginPage(),
        CustomerRegisterPage.routeName: (context) => const CustomerRegisterPage(),
        ProviderRegisterPage.routeName: (context) => const ProviderRegisterPage(),
        WaitingApprovePage.routeName:(context)=> const WaitingApprovePage()
      },
      debugShowCheckedModeBanner: false,
      initialRoute: LoginPage.routeName,
    );
  }
}
