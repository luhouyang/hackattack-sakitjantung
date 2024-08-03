import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakitjantung/pages/chat_page.dart';
import 'package:sakitjantung/pages/home_page.dart';
import 'package:sakitjantung/pages/notification_page.dart';
import 'package:sakitjantung/pages/profile_page.dart';
import 'package:sakitjantung/usecase/navigation_usecase.dart';
import 'package:sakitjantung/utils/constants.dart';

import '../usecase/noti_listener_usecase.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<NotiListenerUseCase, NavigationUseCase>(
        builder: (context, notiUse, navUse, child) {
      return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Image.asset(
              "assets/logo.png",
            ),
          ),
          centerTitle: true,
          title: Text(
            changeTitle(navUse.bottomNavigationIdx),
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color: MyColours.primaryColour,
                fontSize: 26),
          ),
        ),
        body: changePage(navUse.bottomNavigationIdx),
        floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.white,
          backgroundColor: Colors.yellow[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          onPressed:
              notiUse.started ? notiUse.stopListening : notiUse.startListening,
          tooltip: 'Start/Stop sensing',
          child: notiUse.isLoading
              ? const Icon(Icons.close)
              : (notiUse.started
                  ? const Icon(Icons.stop)
                  : const Icon(Icons.play_arrow)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar(
            backgroundColor: MyColours.primaryColour,
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

  String changeTitle(int idx) {
    if (idx == 0) {
      return "STATISTICS";
    } else if (idx == 1) {
      return "NOTIFICATION";
    } else if (idx == 2) {
      return "CHATBOT";
    } else {
      return "PROFILE";
    }
  }
}
