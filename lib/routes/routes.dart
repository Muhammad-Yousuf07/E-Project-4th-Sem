import 'package:authentication/pages/chat_page.dart';
import 'package:authentication/pages/customer_support.dart';
import 'package:authentication/pages/faq_page.dart';
import 'package:authentication/pages/forget_password.dart';
import 'package:authentication/pages/launching_page.dart';
import 'package:authentication/pages/signup_page.dart';
import 'package:authentication/pages/feedback_page.dart';
import 'package:authentication/pages/edit_user_profile.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';

class PageRoutes{
  static const String userHome = HomePage.routeName;
  static const String userLogin = LoginPage.routeName;
  static const String userLaunch = LaunchingPage.routeName;
  static const String userSignup = SignupPage.routeName;
  static const String userResetPass = ForgotPasswordPage.routeName;
  static const String userChat = ChatPage.routeName;
  static const String userFAQ = FAQPage.routeName;
  static const String userCustomerSupport = SupportHomePage.routeName;
  static const String userFeedbackForm = FeedbackFormPage.routeName;
  static const String userEditProfile = EditProfilePage.routeName;



}