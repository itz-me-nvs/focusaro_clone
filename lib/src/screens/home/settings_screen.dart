import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focusaro_clone/src/components/rounded_button.dart';
import 'package:focusaro_clone/src/utils/functions/global_functions.dart';
import 'package:focusaro_clone/src/utils/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<TimeOfDay> selectedTimes = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  AuthProvider _authProvider = AuthProvider();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dynamic userDetails =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    print('user details $userDetails');
    fetchTimesFromFirebase(userDetails['userID']);
  }

  fetchTimesFromFirebase(String userID) {
    selectedTimes = [];
    final DocumentReference userRef = firestore.collection('user').doc(userID);
    userRef.get().then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        final dynamic data = snapshot.data();
        print(data);
        final List<dynamic> timeData = data['focusModeTimes'] ?? [];

        timeData.forEach((time) {
          setState(() {
            selectedTimes.add(convertTimeOfDay(time));
          });
        });
      } else {
        print('Document does not exist');
      }
    }).catchError((error) {
      print('Error fetching document: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final dynamic userDetails =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Focus Mode Time Settings'),
        ),
        body: Column(
          children: [
            RoundedButton(
                color: Colors.blue,
                function: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (time != null) {
                    print(time);
                    print(selectedTimes);
                    // selectedTimes.add(time);
                    setState(() {
                      selectedTimes.add(time);
                    });
                    firestore
                        .collection('user')
                        .doc(userDetails['userID'])
                        .update({
                      'focusModeTimes':
                          selectedTimes.map((e) => e.format(context)).toList()
                    });
                  }
                },
                text: 'Select Time'),
            Expanded(
              child: ListView.builder(
                itemCount: selectedTimes.length,
                itemBuilder: (context, index) {
                  final time = selectedTimes[index];
                  return ListTile(
                    title: Text(time.format(context)),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          selectedTimes.removeAt(index);
                          firestore
                              .collection('user')
                              .doc(userDetails['userID'])
                              .update({
                            'focusModeTimes': selectedTimes
                                .map((e) => e.format(context))
                                .toList()
                          });
                        });
                      },
                      icon: Icon(Icons.delete),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
