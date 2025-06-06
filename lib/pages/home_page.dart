import 'dart:async';
import 'package:authentication/services/authentication.dart';
import 'package:authentication/widgets/auth_guard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/HomePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? uuid;
  late Duration _remainingTime;
  Timer? _timer;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final endTime = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _remainingTime = endTime.difference(now);

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final endTime = DateTime(now.year, now.month, now.day, 23, 59, 59);
      setState(() {
        _remainingTime = endTime.difference(now);
      });
    });

    final user = FirebaseAuth.instance.currentUser ;
    if (user != null) {
      uuid = user.uid;
    }
    _videoController = VideoPlayerController.asset("assets/videos/home_banner_2.mp4")
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        drawer: SideDrawer(),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            backgroundColor: Color(0xFF0e99c9),
            iconTheme: IconThemeData(color: Colors.white, size: 26),
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "⌚ Flash Sale Ends In ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
                _buildStaticTimer(),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await AuthenticationHelper().signOut();
                  Navigator.pushReplacementNamed(context, "/LoginPage");
                },
                icon: Icon(Icons.logout_outlined),
              ),
            ],
          ),
        ),
        body: Container(
          color: Color(0xFFeeeeee),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 120),
                if (_videoController.value.isInitialized)
                  Stack(
                    alignment: Alignment.center,
                    children: [

                      Container(
                        height: MediaQuery.of(context).size.height * 0.69, // 85% of screen height

                        width: double.infinity,
                        child: Opacity(
                          opacity: 1, // Added opacity here
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _videoController.value.size.width,
                              height: _videoController.value.size.height,
                              child: VideoPlayer(_videoController),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 0,
                        child: Text(
                          "WATCH HUB",
                          style: TextStyle(
                            fontSize: 50,
                            letterSpacing: 2,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SizedBox(
                            width: 200, // Fixed width to reduce button size
                            child: ElevatedButton(
                              onPressed: () {
                                // Your action here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0e99c9), // Match your color style
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              child: Text(
                                "SHOP NOW",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  letterSpacing: 3,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 70,
                        child: Text(
                          "PAKISTAN'S NO.1 E-COMMERCE STORE",
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 3,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),




                buildWatchShowcaseSection(
                  context: context,
                  backgroundImage: 'assets/images/watch_bg_1.jpg',
                  watchImage: 'assets/images/watch2.webp',
                  title: "SUBMARINER DATE ",
                  subtitle: "NEW ARRIVAL",
                ),
                buildWatchShowcaseSection(
                  context: context,
                  backgroundImage: 'assets/images/watch_bg_2.jpg',
                  watchImage: 'assets/images/watch1.png',
                  title: "OYSTER PERPETUAL",
                  subtitle: "DIVE INTO EXCELLENCE",
                ),

                buildWatchShowcaseSection(
                  context: context,
                  backgroundImage: 'assets/images/watch_bg_3.jpg',
                  watchImage: 'assets/images/watch3.webp',
                  title: "HORIZON X",
                  subtitle: "BEYOND THE LIMITS",
                ),

                buildWatchShowcaseSection(
                  context: context,
                  backgroundImage: 'assets/images/watch_bg_4.jpg',
                  watchImage: 'assets/images/watch4.webp',
                  title: "STORM MARK",
                  subtitle: "WHERE SAND RAGES",
                ),

                buildWatchShowcaseSection(
                  context: context,
                  backgroundImage: 'assets/images/watch_bg_5.jpg',
                  watchImage: 'assets/images/watch5.png',
                  title: "PATEK PHILIPPE",
                  subtitle: "THE GOLDEN BRIDGE",
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget buildWatchShowcaseSection({
    required BuildContext context,
    required String backgroundImage,
    required String watchImage,
    required String title,
    required String subtitle,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,

      height: isMobile ? 420 : 560,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: isMobile ? 40 : 70,
            child: Column(
              children: [
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 2,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: isMobile ? 80 : 100,
            child: Image.asset(
              watchImage,
              height: isMobile ? 200 : 280,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: isMobile ? 25 : 30,
            child: ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,

                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 28 : 40,
                  vertical: isMobile ? 18 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "DISCOVER MORE",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      letterSpacing: 2,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: isMobile ? 14 : 16,
                  ),
                ],
              ),

            ),
          ),
        ],
      ),
    );
  }




  Widget _buildStaticTimer() {
    final hours = _remainingTime.inHours.toString().padLeft(2, '0');
    final minutes = (_remainingTime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _timeUnitBox(value: hours),
        Text(":", style: TextStyle(color: Colors.white, fontSize: 20)),
        _timeUnitBox(value: minutes),
        Text(":", style: TextStyle(color: Colors.white, fontSize: 20)),
        _timeUnitBox(value: seconds),
      ],
    );
  }

  Widget _timeUnitBox({required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0e99c9),
        ),
      ),
    );
  }
}