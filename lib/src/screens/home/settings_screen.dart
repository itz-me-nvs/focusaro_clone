import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focusaro_clone/src/components/rounded_button.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';
  SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<TimeOfDay> selectedTimes = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTimesFromFirebase();
  }

  fetchTimesFromFirebase() {
    final DocumentReference userRef =
        firestore.collection('user').doc('mINhLg007Rc964sto22qNgibQJ92');
    userRef.get().then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        print(data);
        final List<dynamic> timeData = [];

        timeData.forEach((time) {
          print('times - ${time.toString()}');
          // Parse the time from Firestore data and add to the selectedTimes list
          final List<String> timeParts = time.split(':');
          final int hour = int.parse(timeParts[0]);
          final int minute = int.parse(timeParts[1]);

          final TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);
          setState(() {
            selectedTimes.add(timeOfDay);
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
                    setState(() {
                      selectedTimes.add(time);

                      firestore
                          .collection('user')
                          .doc('mINhLg007Rc964sto22qNgibQJ92')
                          .update({
                        'focusModeTimes':
                            selectedTimes.map((e) => e.format(context)).toList()
                      });
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
                              .doc('mINhLg007Rc964sto22qNgibQJ92')
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
