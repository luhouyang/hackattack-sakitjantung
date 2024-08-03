import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakitjantung/pages/chat_page.dart';
import 'package:sakitjantung/pages/home_page.dart';
import 'package:sakitjantung/pages/notification_page.dart';
import 'package:sakitjantung/pages/profile_page.dart';
import 'package:sakitjantung/usecase/navigation_usecase.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationUseCase>(builder: (context, navUse, child) {
      return Scaffold(
        body: changePage(navUse.bottomNavigationIdx),
        bottomNavigationBar: AnimatedBottomNavigationBar(
            backgroundColor: Colors.blue[900],
            activeColor: Colors.white,
            inactiveColor: Colors.white.withOpacity(0.4),
            activeIndex: navUse.bottomNavigationIdx,
            icons: const [
              Icons.home_rounded,
              Icons.my_library_books_outlined,
              Icons.contact_support_rounded,
              Icons.person
            ],
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.softEdge,
            blurEffect: true,
            leftCornerRadius: 32,
            rightCornerRadius: 32,
            onTap: (index) => navUse.changeIdx(index)),
      );
    });
  }

  Widget changePage(int idx) {
    if (idx == 0) {
      return const HomePage();
    } else if (idx == 1) {
      return const NotificationPage();
    } else if (idx == 2) {
      return const ChatPage();
    } else {
      return const ProfilePage();
    }
  }
}
