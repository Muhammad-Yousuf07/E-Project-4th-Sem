import 'package:authentication/pages/FAQAdmin.dart';
import 'package:authentication/pages/admin_page.dart';
import 'package:authentication/pages/chat_page.dart';
import 'package:authentication/pages/customer_support.dart';
import 'package:authentication/pages/faq_page.dart';
import 'package:authentication/pages/feedback.dart';
import 'package:authentication/pages/forget_password.dart';
import 'package:authentication/pages/launching_page.dart';
import 'package:authentication/pages/signup_page.dart';
import 'package:authentication/pages/feedback_page.dart';
import 'package:authentication/pages/edit_user_profile.dart';
import 'package:authentication/pages/supportAdmin.dart';
import 'package:authentication/pages/user_product.dart';
import 'package:authentication/pages/user_product_details.dart';
import 'package:flutter/cupertino.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/products.dart';

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
  static const String userProducts = UserProductsPage.routeName;
  static const String userProductDetails = ProductDetailPage.routeName;


//   admin routes
  static const String adminPanel = AdminPage.routeName;
  static const String productRoute = ProductsPage.routeName;
  static const String feedbackroute = FeedbackManagementPage.routeName;
  static const String faqsadminroute = FAQAdminPage.routeName;
  static const String supportadminroute = SupportAdminPage.routeName;

}