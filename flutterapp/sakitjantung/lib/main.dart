import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sakitjantung/pages/auth_stream.dart';
import 'package:sakitjantung/services/firebase_services.dart';
import 'package:sakitjantung/usecase/chat_usecase.dart';
import 'package:sakitjantung/usecase/navigation_usecase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import the generated file
import 'firebase_options.dart';
import 'usecase/noti_listener_usecase.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();

  await dotenv.load(fileName: ".env");
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
        ),
        ChangeNotifierProvider(
          create: (context) => FirebaseService(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatUseCase(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: AuthStreamPage()),
      ),
    );
  }
}
