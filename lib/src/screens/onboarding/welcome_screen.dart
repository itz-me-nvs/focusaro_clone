import 'package:flutter/material.dart';
import 'package:focusaro_clone/src/components/rounded_button.dart';
import 'package:focusaro_clone/src/utils/providers/auth_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorTween;

  @override
  void initState() {
    super.initState();
    getPermission();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..forward();

    _colorTween = ColorTween(
      begin: Colors.red,
      end: Colors.blue,
    ).animate(_animationController);
  }

  Future<void> getPermission() async {
    // get permission here
    await Permission.contacts.request();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _colorTween,
        builder: ((context, child) {
          return Scaffold(
              backgroundColor: _colorTween.value ?? Colors.transparent,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Hero(
                          tag: 'logo',
                          child: CircleAvatar(
                            backgroundImage: AssetImage('images/figma.jpg'),
                            radius: 40.0,
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          'Focusaro',
                          style: TextStyle(
                            fontSize: 40.0,
                            color: _colorTween.isCompleted
                                ? Colors.white
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 70.0,
                          ),
                          child: RoundedButton(
                            color: Colors.white,
                            function: () {
                              String targetPath = 'phone_auth_screen';
                              final authProvider = Provider.of<AuthProvider>(
                                  context,
                                  listen: false);
                              print('login status is ${authProvider.user}');
                              targetPath = authProvider.isLoggedIn
                                  ? 'home_screen'
                                  : 'phone_auth_screen';
                              dynamic routeparams = authProvider.isLoggedIn
                                  ? {
                                      'phoneNumber':
                                          authProvider.user!.phoneNumber,
                                      'userID': authProvider.user!.userID
                                    }
                                  : 'welcome';

                              // Navigate to the target route based on the user's auth status
                              Navigator.pushNamed(context, targetPath,
                                  arguments: routeparams);
                            },
                            text: 'Continue',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
        }));
  }
}
