import 'package:flutter/material.dart';
import 'package:focusaro_clone/src/utils/providers/app_state_notifier.dart';
import 'package:provider/provider.dart';

class SampleScreen extends StatefulWidget {
  const SampleScreen({Key? key}) : super(key: key);
  @override
  _SampleScreen createState() => _SampleScreen();
}

class _SampleScreen extends State<SampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Name ${Provider.of<AppStateNotifier>(context).isDarkMode ? 'Dark' : 'Light'}'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
            'Sample Screens',
            style: TextStyle(fontSize: 24),
          ),
          OutlinedButton(
              onPressed: () {
                Provider.of<AppStateNotifier>(context, listen: false)
                    .updateTheme(
                        !Provider.of<AppStateNotifier>(context, listen: false)
                            .isDarkMode);
              },
              child: Text(Provider.of<AppStateNotifier>(context).isDarkMode
                  ? 'Light'
                  : 'Dark')),
          OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Login')),
        ]),
      ),
    );
  }
}
