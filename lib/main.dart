import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'models/contact_model.dart';
import 'pages/register_page.dart';
import 'pages/login_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/profile_page.dart';
import 'pages/homepage.dart';
import 'pages/contact_details_page.dart';
import 'pages/camera_page.dart';
import 'pages/form_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = GoRouter(
    initialLocation: LoginPage.routeName,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        name: RegisterPage.routeName,
        path: RegisterPage.routeName,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        name: LoginPage.routeName,
        path: LoginPage.routeName,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        name: ForgotPasswordPage.routeName,
        path: ForgotPasswordPage.routeName,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        name: ProfilePage.routeName,
        path: ProfilePage.routeName,
        builder: (_, __) => const ProfilePage(),
      ),
      GoRoute(
        name: HomePage.routeName,
        path: HomePage.routeName,
        builder: (_, __) => const HomePage(),
        routes: [
          GoRoute(
            name: ContactDetailsPage.routeName,
            path: ContactDetailsPage.routeName,
            builder: (_, state) =>
                ContactDetailsPage(contact: state.extra! as ContactModel),
          ),
          GoRoute(
            name: CameraPage.routeName,
            path: CameraPage.routeName,
            builder: (_, __) => const CameraPage(),
            routes: [
              GoRoute(
                name: FormPage.routeName,
                path: FormPage.routeName,
                builder: (_, state) =>
                    FormPage(contactModel: state.extra! as ContactModel),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Virtual Visiting Card',
      routerConfig: _router,
      builder: EasyLoading.init(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}