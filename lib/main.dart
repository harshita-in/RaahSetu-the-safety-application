// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart'; // We will create this next
import 'screens/home_screen.dart'; // We will create this next

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RaahSetuApp());
}

class RaahSetuApp extends StatelessWidget {
  const RaahSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the app with the AuthService to make it accessible everywhere
    return StreamProvider<User?>.value(
      initialData: null,
      value: AuthService().user, // Stream that listens for Auth State changes
      child: MaterialApp(
        title: 'RaahSetu',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
        ),
        home: const AuthWrapper(), // The initial screen
      ),
    );
  }
}

// This widget decides which screen to show based on the user's state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the User object from the StreamProvider
    final user = Provider.of<User?>(context);

    if (user == null) {
      // User is NOT signed in: show the login/register screen
      return const AuthenticationScreen();
    } else {
      // User IS signed in: show the main application (Map) screen
      return const HomeScreen();
    }
  }
}

// NOTE: We will keep these simple placeholders for now to allow compilation

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(child: Text('Authentication Screen (Next Step)'))
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RaahSetu Home (Map)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome! You are signed in.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signOut();
              },
              child: const Text('Sign Out (Test Auth Service)'),
            ),
          ],
        ),
      ),
    );
  }
}