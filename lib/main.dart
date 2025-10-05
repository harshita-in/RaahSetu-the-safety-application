import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/auth_services.dart';
import 'screens/auth_screen.dart';

// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("🔔 Background message received: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const RaahSetuApp());
}

class RaahSetuApp extends StatefulWidget {
  const RaahSetuApp({super.key});

  @override
  State<RaahSetuApp> createState() => _RaahSetuAppState();
}

class _RaahSetuAppState extends State<RaahSetuApp> {
  @override
  void initState() {
    super.initState();

    // Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("🔔 Foreground message: ${message.notification!.title}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.notification!.body ?? "New alert")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RaahSetu',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: const AuthScreen(),
      ),
    );
  }
}
