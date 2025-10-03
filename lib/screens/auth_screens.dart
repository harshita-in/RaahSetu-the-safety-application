import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import 'phone_auth_screen.dart';
import 'map_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("RaahSetu - Authentication")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // 🔹 Login / Signup Button
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                  setState(() => loading = true);
                  try {
                    if (isLogin) {
                      await auth.signIn(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      // ✅ Navigate to MapScreen after login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MapScreen()),
                      );
                    } else {
                      await auth.signUp(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      // ✅ Navigate to MapScreen after signup
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MapScreen()),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                  setState(() => loading = false);
                },
                child: Text(isLogin ? "Login" : "Sign Up"),
              ),

              // 🔹 Switch between Login/Signup
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin
                    ? "Don't have an account? Sign Up"
                    : "Already have an account? Login"),
              ),

              const Divider(height: 40, thickness: 1),

              // 🔹 Phone OTP Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
                  );
                },
                icon: const Icon(Icons.phone),
                label: const Text("Login with Phone Number"),
              ),
              const SizedBox(height: 10),

              // 🔹 Google Sign-In Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    final googleAuth = GoogleAuthService();
                    final user = await googleAuth.signInWithGoogle();
                    if (user != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Google Login Success: ${user.email}")),
                      );
                      // ✅ Navigate to MapScreen after Google login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MapScreen()),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text("Sign in with Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
