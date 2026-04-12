import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/networks/cache_helper.dart';
import 'package:herafy/core/networks/dio_helpers.dart';
import 'package:herafy/core/resourses/app_theme.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/screens/customer/customer_register_page.dart';
import 'package:herafy/features/auth/screens/login.dart';
import 'package:herafy/features/auth/screens/role_selection.dart';
import 'package:herafy/features/auth/screens/services_provider/provider_register_page.dart';
import 'package:herafy/features/auth/screens/waiting_approve_page.dart';
import 'package:herafy/features/home/cubits/posts_comments/posts_and_comments_cubit.dart';
import 'package:herafy/features/home/screens/PagesView/offers_and_quick_request_for_client/screens/offers_page.dart';
import 'package:herafy/features/home/screens/PagesView/offers_and_quick_request_for_client/screens/quick_request_page.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/pages/provider_dashboard_page.dart';
import 'package:herafy/features/screens/complete_data.dart';
import 'package:herafy/features/screens/create_post_screen.dart';
import 'package:herafy/features/screens/edit_account_page.dart';
import 'package:herafy/features/home/screens/home_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DioHelper.initDio();
  runApp(const HerafyApp());
}

class HerafyApp extends StatefulWidget {
  const HerafyApp({super.key});

  @override
  State<HerafyApp> createState() => _HerafyAppState();
}

class _HerafyAppState extends State<HerafyApp> {
  late Future<String> _initialRouteFuture;
  late AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit();
    _initialRouteFuture = _determineInitialRoute();
  }

  Future<String> _determineInitialRoute() async {
    try {
      await _authCubit.loadUserData();
      final token = await CacheHelper.getToken();
      final user = _authCubit.currentUser;

      if (token != null && token.isNotEmpty && user != null) {
        if (user.status == 0) {
          return CompleteDataScreen.routeName;
        }
        return HomePage.routeName;
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return LoginPage.routeName;
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialRouteFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('جاري التحميل...'),
                  ],
                ),
              ),
            ),
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: _authCubit),
            BlocProvider<SocialCubit>(create: (_) => SocialCubit()),
          ],
          child: MaterialApp(
            routes: {
              RoleSelectionPage.routeName: (context) =>
                  const RoleSelectionPage(),
              LoginPage.routeName: (context) => const LoginPage(),
              CustomerRegisterPage.routeName: (context) =>
                  const CustomerRegisterPage(),
              ProviderRegisterPage.routeName: (context) =>
                  const ProviderRegisterPage(),
              WaitingApprovePage.routeName: (context) =>
                  const WaitingApprovePage(),
              HomePage.routeName: (context) => const HomePage(),
              EditAccountPage.routeName: (context) => const EditAccountPage(),
              CreatePostScreen.routeName: (context) => const CreatePostScreen(),
              CompleteDataScreen.routeName: (context) =>
                  const CompleteDataScreen(),
              ProviderDashboardPage.routeName: (context) =>
                  const ProviderDashboardPage(),
              QuickRequestPage.routeName: (context) => const QuickRequestPage(),
              OffersPage.routeName: (context) => const OffersPage(),
            },
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute:
                OffersPage.routeName, // snapshot.data ?? HomePage.routeName,
            // snapshot.data ?? LoginPage.routeName,
          ),
        );
      },
    );
  }
}


// role != Provider -> Client UI عادي.
// role == Provider && !isProfileComplete -> Client UI + CTA إكمال البيانات.
// role == Provider && isProfileComplete && !isAuthenticated -> Client UI + حالة انتظار.
// role == Provider && isProfileComplete && isAuthenticated -> Provider UI كامل.