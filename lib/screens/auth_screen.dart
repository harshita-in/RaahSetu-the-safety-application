import 'phone_auth_screen.dart';


TextButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
);
},
child: const Text("Login with Phone Number"),
),
