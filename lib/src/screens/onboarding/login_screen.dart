import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusaro_clone/src/components/rounded_button.dart';
import 'package:focusaro_clone/src/config/constants.dart';
import 'package:focusaro_clone/src/screens/home/message_list_screen.dart';
import 'package:focusaro_clone/src/utils/providers/auth_provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

final _firestore = FirebaseFirestore.instance;

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  late String username, password;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    final Map data = ModalRoute.of(context)?.settings.arguments as dynamic;
    print(data);
    return Scaffold(
      backgroundColor: Colors.black,
      body: ModalProgressHUD(
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
                    child: TextField(
                      keyboardType: TextInputType.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                      onChanged: (value) {
                        //Do something with the user input.
                        username = value;
                      },
                      decoration: kTextFileDecoration.copyWith(
                        hintText: 'Username',
                        hintStyle: kcolor.copyWith(
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70.0),
                child: RoundedButton(
                  function: () async {
                    setState(
                      () {
                        showSpinner = true;
                      },
                    );
                    try {
                      _firestore
                          .collection('user')
                          .doc(data['userId'].toString())
                          .set(
                        {
                          'userId': data['userId'],
                          'phoneNumber': data['phoneNumber'],
                          'userName': username,
                          'focusMode': false,
                          'photoUrl':
                              'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.6qHDJF8Tc0NOMgaWlq8VkQAAAA%26pid%3DApi&f=1',
                          'isOnline': false,
                          'focusLocation': [0.0, 0.0],
                        },
                      );
                      print(data['userId'].toString() + data['phoneNumber']);

                      // retrieve the authProvider instance
                      AuthProvider authProvider =
                          Provider.of<AuthProvider>(context, listen: false);

                      // Call the login method and pass the necessary values
                      await authProvider.login(
                          data['phoneNumber'], data['userId']);

                      print(authProvider.user);

                      // ignore: use_build_context_synchronously
                      Navigator.popAndPushNamed(
                        context,
                        MessageListScreen.id,
                        arguments: {
                          'phoneNumber': data['phoneNumber'],
                          'userID': data['userId']
                        },
                      );

                      setState(() {
                        showSpinner = false;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  color: Colors.lightBlueAccent,
                  text: '                  ',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
