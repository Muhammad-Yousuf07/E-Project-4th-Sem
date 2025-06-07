import 'package:authentication/firebase_options.dart';
import 'package:authentication/pages/admin_page.dart';
import 'package:authentication/pages/chat_page.dart';
import 'package:authentication/pages/customer_support.dart';
import 'package:authentication/pages/edit_user_profile.dart';
import 'package:authentication/pages/faq_page.dart';
import 'package:authentication/pages/feedback_page.dart';
import 'package:authentication/pages/forget_password.dart';
import 'package:authentication/pages/home_page.dart';
import 'package:authentication/pages/launching_page.dart';
import 'package:authentication/pages/login_page.dart';
import 'package:authentication/pages/signup_page.dart';
import 'package:authentication/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ecommerce App",
      home: LaunchingPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(


        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 24),
          iconTheme: IconThemeData(color: Colors.white, weight: 20, size: 26)
        ),
      ),
      initialRoute: "/LaunchingPage",
      routes: {
        PageRoutes.userHome : (context) => HomePage(),
        PageRoutes.userLogin : (context) => LoginPage(),
        PageRoutes.userSignup : (context) => SignupPage(),
        PageRoutes.userLaunch : (context) => LaunchingPage(),
        PageRoutes.userResetPass : (context) => ForgotPasswordPage(),
        PageRoutes.userChat : (context) => ChatPage(),
        PageRoutes.userFAQ : (context) => FAQPage(),
        PageRoutes.userCustomerSupport : (context) => SupportHomePage(),
        PageRoutes.userFeedbackForm : (context) => FeedbackFormPage(),
        PageRoutes.userEditProfile : (context) => EditProfilePage(),
        PageRoutes.adminPanel : (context) => AdminPage(),
      },
    );
  }
}

