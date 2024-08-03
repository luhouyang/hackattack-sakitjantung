import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakitjantung/pages/notification_page.dart';
import 'package:sakitjantung/usecase/navigation_usecase.dart';

import 'usecase/noti_listener_usecase.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NotiListenerUseCase(),
        ),
        ChangeNotifierProvider(
          create: (context) => NavigationUseCase(),
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: NotificationPage()),
      ),
    );
  }
}
