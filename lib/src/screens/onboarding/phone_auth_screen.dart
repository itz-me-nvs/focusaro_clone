import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusaro_clone/src/screens/onboarding/login_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  static const String id = 'phone_auth_screen';
  final String title = '';

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  late String _verificationId;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _verifyPhoneNumber(BuildContext context) async {
    final String phoneNumber = _phoneNumberController.text;
    await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          showSnackbar(
              "Phone number automatically verified and user signed in: ${_auth.currentUser?.uid}");
          // ignore: use_build_context_synchronously
          Navigator.popAndPushNamed(
            context,
            LoginScreen.id,
            arguments: {
              'userId': _auth.currentUser?.uid,
              'phoneNumber': _phoneNumberController.text,
            },
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Invalid Phone Number'),
                  content: Text('Please enter a valid phone number.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Enter SMS Code'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _smsController,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Submit'),
                    onPressed: () async {
                      final String smsCode = _smsController.text.trim();
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: smsCode,
                      );
                      await _auth.signInWithCredential(credential);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushNamed(
                        'login_screen',
                        arguments: {
                          'userId': _auth.currentUser?.uid,
                          'phoneNumber': _phoneNumberController.text,
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
        timeout: const Duration(seconds: 120),
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  void showSnackbar(String message) {
    final snackbar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    );
    (_scaffoldkey.currentState as dynamic).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    print('i am here');
    String? greeting = ModalRoute.of(context)?.settings.arguments as String?;
    print(greeting);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          // elevation: 50.0,
          backgroundColor: Colors.blue,
          bottom: const PreferredSize(
              child: const Padding(padding: EdgeInsets.all(8.0)),
              preferredSize: Size.fromHeight(20.0)),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Center(
                child: Text(
                  'Phone Number Authentication',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        key: _scaffoldkey,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 35.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextFormField(
                cursorColor: Colors.blue,
                maxLength: 10,
                keyboardType: TextInputType.phone,
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.phone),
                  labelText: '+91',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: OutlinedButton(
                child: const Text("Send OTP"),
                onPressed: () async {
                  _verifyPhoneNumber(context);
                },
              ),
            )
          ],
        ));
  }
}
