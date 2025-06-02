import 'package:authentication/pages/chat_page.dart';
import 'package:authentication/pages/faq_page.dart';
import 'package:authentication/widgets/auth_guard.dart';
import 'package:flutter/material.dart';

import '../services/authentication.dart';
import '../widgets/drawer.dart';

class SupportHomePage extends StatelessWidget {
  static const String routeName = '/CustomerSupportPage';
  const SupportHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        drawer: SideDrawer(),
        appBar: AppBar(
          title: const Text('Customer Support', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
          actions: <Widget>[
            IconButton(
              onPressed: () async{
                await AuthenticationHelper().signOut();
                Navigator.pushReplacementNamed(context, "/LoginPage");
              },
              icon: Icon(Icons.logout_outlined),
            )
          ],
          backgroundColor: Color(0xFF0e99c9),
          iconTheme: IconThemeData(color: Colors.white, weight: 20, size: 26),
          centerTitle: true,
        ),
        body: Container(
          color: Color(0xFFeeeeee),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              children: [
                SupportOption(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat with Support',
                  description: 'Instant help from our team',
                  color: Color(0xFF0e99c9),
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatPage()));
                  }
                ),
                const SizedBox(height: 25),
                SupportOption(
                  icon: Icons.help_outline,
                  title: 'FAQs',
                  description: 'Find quick answers to common questions',
                  color: Color(0xFF0e99c9),
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FAQPage()));
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SupportOption extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const SupportOption({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  State<SupportOption> createState() => _SupportOptionState();
}

class _SupportOptionState extends State<SupportOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 32, color: widget.color),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}