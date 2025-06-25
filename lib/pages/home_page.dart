import 'dart:async';

import 'package:flutter/material.dart' ;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../services/authentication.dart';
import '../widgets/drawer.dart';
import 'user_product.dart';
import 'user_product_details.dart';
import 'products.dart';
import 'package:authentication/widgets/auth_guard.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/HomePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*────────────  sale-timer state  ────────────*/
  late Duration _remainingTime;
  Timer? _timer;

  /*────────────  bottom-bar state  ───────────*/
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // ── sale countdown until 23:59:59 tonight ──
    final now = DateTime.now();
    final endTime = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _remainingTime = endTime.difference(now);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final endTime = DateTime(now.year, now.month, now.day, 23, 59, 59);
      setState(() => _remainingTime = endTime.difference(now));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /*────────────  bottom-bar tap handler ───────────*/
  void _onNavTap(int index) {
    if (index == 3) {
      // Profile icon → jump to your edit-profile route
      Navigator.pushReplacementNamed(context, "/EditUserPage");
    }
    else if (index == 1){
      Navigator.pushReplacementNamed(context, "/ProductPage");

    }

    else {
      setState(() => _selectedIndex = index);
    }
  }



  /*────────────  page switcher ───────────*/
  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeBody();
      case 1:
        return const ExploreTab();
      case 2:
        return const CartTab();
      default:
        return _buildHomeBody();
    }
  }

  /*────────────  sale timer widget ───────────*/
  Widget _buildStaticTimer() {
    final h = _remainingTime.inHours.toString().padLeft(2, '0');
    final m = (_remainingTime.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');

    Widget box(String v) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        v,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0e99c9),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        box(h),
        const Text(":", style: TextStyle(color: Colors.white, fontSize: 20)),
        box(m),
        const Text(":", style: TextStyle(color: Colors.white, fontSize: 20)),
        box(s),
      ],
    );
  }

  /*────────────  scaffold ───────────*/
  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        drawer: const SideDrawer(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            backgroundColor: const Color(0xFF0e99c9),
            iconTheme: const IconThemeData(color: Colors.white, size: 26),
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "⌚ Sale Ends In ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                _buildStaticTimer(),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await AuthenticationHelper().signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, "/LoginPage");
                  }
                },
                icon: const Icon(Icons.logout_outlined),
              ),
            ],
          ),
        ),

        // body changes when user taps the bar (except Profile)
        body: _buildSelectedPage(),

        /*────────────  bottom navigation bar  ───────────*/
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF0e99c9),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  /*────────────  home tab content ───────────*/
  Widget _buildHomeBody() => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: const [
          HomeHeader(),
          DiscountBanner(),
          Categories(),
          SizedBox(height: 20),
          LatestProducts(),
          TestimonialSection(),
          SizedBox(height: 20),
        ],
      ),
    ),
  );
}

/*━━━━━━━━━━  placeholder tabs  ━━━━━━━━━━*/
class ExploreTab extends StatelessWidget {
  const ExploreTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Explore page (coming soon)'));
}

class CartTab extends StatelessWidget {
  const CartTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Cart page (coming soon)'));
}

/*─────────────────────────────────
  Everything below is copied from
  your original file unchanged. If
  you keep these widgets in their
  own files, you can delete them
  here and import instead.
─────────────────────────────────*/

// ---------------- HomeHeader ----------------
class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Watches...',
                prefixIcon: const Icon(Icons.search),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconBtnWithCounter(
            svgSrc: "assets/icons/Heart Icon.svg",
            numOfitem: 0,
            press: () {},
          ),
          IconBtnWithCounter(
            svgSrc: "assets/icons/Cart Icon.svg",
            numOfitem: 0,
            press: () {},
          ),
        ],
      ),
    );
  }
}



class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: TextFormField(
        onChanged: (value) {},
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF5F6F9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: searchOutlineInputBorder,
          focusedBorder: searchOutlineInputBorder,
          enabledBorder: searchOutlineInputBorder,
          hintText: "Search product",
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

const searchOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide.none,
);

class IconBtnWithCounter extends StatelessWidget {
  const IconBtnWithCounter({
    Key? key,
    required this.svgSrc,
    this.numOfitem = 0,
    required this.press,
  }) : super(key: key);

  final String svgSrc;
  final int numOfitem;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: press,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F9),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(svgSrc),
          ),
          if (numOfitem != 0)
            Positioned(
              top: -3,
              right: 0,
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4848),
                  shape: BoxShape.circle,
                  border: Border.all(width: 1.5, color: Colors.white),
                ),
                child: Center(
                  child: Text(
                    "$numOfitem",
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class DiscountBanner extends StatelessWidget {
  const DiscountBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0072FF), // Deep Sky Blue
            Color(0xFF00C6FF), // Rich Cyan
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text.rich(
        TextSpan(
          style: TextStyle(color: Colors.white),
          children: [
            TextSpan(text: "WatchHub Summer Fever\n"),
            TextSpan(
              text: "Enjoy 20% Off Instantly",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categories = [
      {"icon": "assets/icons/Flash Icon.svg", "text": "Flash Deal"},
      {"icon": "assets/icons/Bill Icon.svg", "text": "Bill"},
      {"icon": "assets/icons/Parcel.svg", "text": "Parcel"},
      {"icon": "assets/icons/Gift Icon.svg", "text": "Daily Gift"},
      {"icon": "assets/icons/Discover.svg", "text": "More"},
    ];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          categories.length,
              (index) => CategoryCard(
            icon: categories[index]["icon"],
            text: categories[index]["text"],
            press: () {},
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.press,
  }) : super(key: key);

  final String icon, text;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFeeeeee),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(icon),
          ),
          const SizedBox(height: 4),
          Text(text, textAlign: TextAlign.center)
        ],
      ),
    );
  }
}

class LatestProducts extends StatefulWidget {
  const LatestProducts({super.key});

  @override
  State<LatestProducts> createState() => _LatestProductsState();
}

class _LatestProductsState extends State<LatestProducts> {
  late Future<List<QueryDocumentSnapshot>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = FirebaseFirestore.instance
        .collection('products')
        .orderBy('createdAt', descending: true)
        .limit(6)
        .get()
        .then((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Latest Products",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, UserProductsPage.routeName);
                },
                child: const Text("See more", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
        FutureBuilder<List<QueryDocumentSnapshot>>(
          future: _futureProducts, // ✅ Cached in initState
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text("No products found."),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: snapshot.data!.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['name'] ?? 'No Name';
                  final imageUrls = List<String>.from(data['images'] ?? []);
                  final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';
                  final price = data['price'] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/ProductDetailPage",
                          arguments: doc.id,
                        );
                      },
                      child: Container(
                        width: 140,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: imageUrl.isNotEmpty
                                  ? Image.network(imageUrl, fit: BoxFit.cover)
                                  : const Icon(Icons.image_not_supported),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '\$${data['price']?.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0e99c9),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList()
                  ,
              ),
            );
          },
        ),
      ],
    );



  }

}

class TestimonialSection extends StatefulWidget {
  const TestimonialSection({super.key});

  @override
  State<TestimonialSection> createState() => _TestimonialSectionState();
}

class _TestimonialSectionState extends State<TestimonialSection> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _activeIndex = 0;
  Timer? _autoTimer;

  // ✅ 1) add a `gender` field
  final List<Map<String, String>> _testimonials = [
    {
      'name': 'Ayesha Khan',
      'role': 'UI/UX Designer',
      'gender': 'female',
      'review':
      'This watch exceeded my expectations! Looks way better than the pictures. Highly recommend WatchHub 💙',
    },
    {
      'name': 'Hamza Iqbal',
      'role': 'Photographer',
      'gender': 'male',
      'review':
      'Fast delivery, sleek design, great support. Easily the best online buying experience.',
    },
    {
      'name': 'Mehwish Saleem',
      'role': 'Software Engineer',
      'gender': 'female',
      'review':
      'Premium quality and always on time. WatchHub is now my go-to place for watches!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients) {
        final next = (_activeIndex + 1) % _testimonials.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'What our customers say',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
    const SizedBox(height: 4),
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _testimonials.length,
            onPageChanged: (i) => setState(() => _activeIndex = i),
            itemBuilder: (_, i) => AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: _activeIndex == i ? 0 : 12,
              ),
              child: _TestimonialCard(_testimonials[i]),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _testimonials.length,
                (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
              width: _activeIndex == i ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _activeIndex == i
                    ? const Color(0xff0e99c9)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),

              ),

            ),
          ),
        ),
      ],

    );

  }

}
/* ───────────── single testimonial card ───────────── */
class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard(this.data);
  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {

    IconData faceIcon;
    switch (data['gender']) {
      case 'female':
        faceIcon = Icons.face_4_rounded; // female-looking face
        break;
      case 'male':
        faceIcon = Icons.face_6_rounded; // male-looking face
        break;
      default:
        faceIcon = Icons.face; // neutral fallback
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff0e99c9),
            const Color(0xff0e99c9).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.15),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /* avatar icon */
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(faceIcon, size: 36, color: const Color(0xff0e99c9)),
          ),
          const SizedBox(height: 12),

          /* review text */
          Text(
            data['review']!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 14),

          /* name & role */
          Text(
            data['name']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            data['role']!,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
