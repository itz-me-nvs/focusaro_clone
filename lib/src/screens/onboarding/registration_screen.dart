import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusaro_clone/src/components/rounded_button.dart';
import 'package:focusaro_clone/src/config/constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../home/message_list_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'Registration_Screen';

  const RegistrationScreen({super.key});
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool showSpinner = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Form(
          key: _formKey,
          child: ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Flexible(
                    child: Hero(
                      tag: 'logo',
                      child: CircleAvatar(
                        backgroundImage: AssetImage('images/figma.jpg'),
                        radius: 100.0,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextFormField(
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                            onChanged: (values) {
                              setState(() {
                                _email.text = values;
                              });
                            },
                            keyboardType: TextInputType.emailAddress,
                            textAlign: TextAlign.center,
                            decoration: kTextFileDecoration.copyWith(
                              hintText: 'Enter your email',
                              hintStyle: kcolor.copyWith(
                                color: Colors.white24,
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextFormField(
                            controller: _password,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                            obscureText: true,
                            textAlign: TextAlign.center,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            decoration: kTextFileDecoration.copyWith(
                              hintText: 'Password',
                              hintStyle: kcolor.copyWith(
                                color: Colors.white24,
                              ),
                            )),
                      ),
                      RoundedButton(
                        function: () async {
                          setState(() {
                            showSpinner = true;
                          });
                          //Implement registration functionality.
                          try {
                            final newUser =
                                await _auth.createUserWithEmailAndPassword(
                                    email: _email.text,
                                    password: _password.text);
                            print('new user result $newUser');
                            if (newUser.user != null) {
                              Navigator.pushNamed(
                                  context, MessageListScreen.id);
                            }
                            // setState(() {
                            //   // showSpinner = false;
                            //   // _formKey.currentState?.reset();
                            //   _formKey.currentState?.validate();
                            // });
                          } catch (e) {
                            print('error here $e');
                          }
                        },
                        color: Colors.blueAccent,
                        text: 'Sign Up',
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
