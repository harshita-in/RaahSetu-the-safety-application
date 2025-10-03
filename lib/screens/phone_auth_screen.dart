import 'package:flutter/material.dart';
import '../services/phone_auth_service.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? verificationId;
  bool otpSent = false;

  final PhoneAuthService _phoneAuthService = PhoneAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!otpSent)
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Enter Phone (+91xxxxxxxxxx)",
                ),
                keyboardType: TextInputType.phone,
              ),
            if (otpSent)
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                ),
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!otpSent) {
                  _phoneAuthService.verifyPhoneNumber(
                    phoneNumber: _phoneController.text.trim(),
                    codeSent: (id) {
                      setState(() {
                        otpSent = true;
                        verificationId = id;
                      });
                    },
                    onError: (err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $err")),
                      );
                    },
                  );
                } else {
                  _phoneAuthService.verifyOTP(
                    verificationId: verificationId!,
                    smsCode: _otpController.text.trim(),
                    onSuccess: (user) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Phone Login Success ✅")),
                      );
                    },
                    onError: (err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $err")),
                      );
                    },
                  );
                }
              },
              child: Text(otpSent ? "Verify OTP" : "Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
