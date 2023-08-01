import 'dart:math' show cos, sqrt, asin;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:focusaro_clone/src/screens/home/chat_screen.dart';
import 'package:focusaro_clone/src/screens/home/location_screen.dart';
import 'package:focusaro_clone/src/utils/functions/global_functions.dart';
import 'package:focusaro_clone/src/utils/providers/auth_provider.dart';
import 'package:focusaro_clone/src/utils/services/location_services.dart';
import 'package:focusaro_clone/src/utils/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MessageListScreen extends StatefulWidget {
  static const String id = 'home_screen';
  final String phoneNumber = '9961542144';
  const MessageListScreen({super.key});

  @override
  _MessageListScreen createState() => _MessageListScreen();
}

class _MessageListScreen extends State<MessageListScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  String photoUrl = '';
  Map<String, Color> contactsColorMap = {};
  TextEditingController searchController = TextEditingController();
  String? userID = '';

  List<Contact> user = [];
  bool focusMode = false;

  void changeFocusMode(bool isFocusMode) {
    setState(() {
      focusMode = isFocusMode;
    });
  }

  @override
  void initState() {
    super.initState();
    getPermissions();
  }

  handleScheduledAction() {
    setSilentMode();
  }

  tz.TZDateTime _parseScheduledTime(String payload) {
    // Implement the logic to parse the time from the payload.
    // For example, if the payload is "10:00", you can parse it like this:
    List<String> timeParts = payload.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    return tz.TZDateTime(tz.local, DateTime.now().year, DateTime.now().month,
        DateTime.now().day, hour, minute);
  }

  Future<void> scheduleNotification(String currentUserID) async {
    // Define your list of times here.
    List<String> times = [];
    final DocumentReference userRef =
        _firestore.collection('user').doc(currentUserID);
    userRef.get().then((DocumentSnapshot snapshot) async {
      if (snapshot.exists) {
        final dynamic data = snapshot.data();
        print('result $data');
        final List<dynamic> timeData = data['focusModeTimes'] ?? [];
        timeData.forEach((element) {
          TimeOfDay time = convertTimeOfDay(element);
          String hour = time.hour.toString().padLeft(2, '0');
          String minute = time.minute.toString().padLeft(2, '0');
          times.add('$hour:$minute');
        });
      } else {
        print('Document does not exist');
      }

      print('ueerugb $times');

      // timezone initialization
      tz.initializeTimeZones();
      final String timeZoneName =
          await FlutterNativeTimezone.getLocalTimezone();
      // Set the local time zone
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      final now = tz.TZDateTime.now(tz.local);

      for (var time in times) {
        // Parse the time string and create a TZDateTime object for today.
        List<String> timeParts = time.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        tz.TZDateTime scheduledDate =
            tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

        // If the scheduled time has already passed for today, schedule it for the next day.
        if (scheduledDate.isBefore(now)) {
          print('scheduled date is before now');
          scheduledDate = scheduledDate.add(Duration(days: 1));
        }

        // Schedule the notification
        NotificationService.scheduleNotification(
            scheduledDate, time, handleScheduledAction);
      }
    });
  }

  getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      getAllContacts();

      searchController.addListener(() {
        filterContacts();
      });
    }
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  getAllContacts() async {
    AuthProvider _authProvider = AuthProvider();
    List colors = [Colors.green, Colors.indigo, Colors.yellow, Colors.orange];
    int colorIndex = 0;
    // List<Contact> contacts = (await ContactsService.getContacts()).toList();
    // print('contact list $contacts');

// isEqualTo: contact.phones?.first.value
//                   ?.replaceAll(' ', '')
//                   .replaceAll('+91', ''),

    // for (var contact in contacts) {
    try {
      _firestore
          .collection('user')
          .where('phoneNumber', isEqualTo: _authProvider.user?.phoneNumber)
          .get()
          .then((value) => value.docs.forEach((element) {
                Map<String, dynamic> userDetails = element.data();
                print(element.data());
                if (userDetails['phoneNumber'] != null) {
                  print(userDetails["phoneNumber"]);
                  user.add(Contact(
                    displayName: userDetails['userName'],
                    phones: [
                      Item(
                        label: 'mobile',
                        value: userDetails['phoneNumber'],
                      )
                    ],
                  ));

                  setState(() {
                    print('user list $user');
                    contacts = user;
                    // print('length ${contacts.length}');
                  });
                }
              }));
    } catch (e) {
      print(e);
    }

    /* Setting a random color if contact does not have one */
    Color baseColor = colors[colorIndex];
    contactsColorMap[contacts[0].displayName!] = baseColor;
    colorIndex++;
    if (colorIndex == colors.length) {
      colorIndex = 0;
    }
  }

  filterContacts() {
    List<Contact> contacts = [];
    contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName!.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones?.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value!);
          return phnFlattened.contains(searchTermFlatten);
        });

        return phone != null;
      });
    }
    setState(() {
      contactsFiltered = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    // get user details from modalRoute

    final dynamic userDetails =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String phoneNumber = userDetails['phoneNumber'];
    final String userID = userDetails['userID'];

    scheduleNotification(userID);
    bool isSearching = searchController.text.isNotEmpty;

    return Scaffold(
        backgroundColor: focusMode ? Colors.black : Colors.white,
        floatingActionButton: focusMode
            ? null
            : FloatingActionButton(
                child: const Icon(Icons.location_on),
                onPressed: () {
                  Navigator.pushNamed(context, LocationScreen.id,
                      arguments: {'userID': userID});
                },
              ),
        appBar: AppBar(
          backgroundColor: Colors.blue,
          automaticallyImplyLeading: false,
          bottom: const PreferredSize(
              child: Padding(padding: EdgeInsets.all(8.0)),
              preferredSize: Size.fromHeight(27.0)),
          title: const Padding(
            padding: const EdgeInsets.only(
              right: 20.0,
              top: 20.0,
              left: 20.0,
            ),
            child: const Text(
              'Inbox',
              style: TextStyle(
                fontSize: 23.0,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                right: 0.0,
                top: 20.0,
              ),
              child: CupertinoSwitch(
                value: focusMode,
                activeColor: Colors.teal[700],
                onChanged: (value) {
                  setState(() {
                    focusMode = value;
                  });

                  // firebase code to update focus mode
                  _firestore
                      .collection('user')
                      .doc(userID)
                      .update({'focusMode': value});
                },
              ),
            ),
          ],
        ),
        body: StreamProvider<UserLocation>(
            create: (context) => LocationService().locationStream,
            initialData:
                UserLocation(latitude: 0.0, longitude: 0.0, focus: false),
            child: Body(
              searchController: searchController,
              contacts: contacts,
              contactsColorMap: contactsColorMap,
              contactsFiltered: contactsFiltered,
              isSearching: isSearching,
              listItemsExist: (contacts.length > 0),
              phoneNumber: phoneNumber,
              changeFocusMode: changeFocusMode,
              isFocusMode: focusMode,
              userId: userID,
              key: UniqueKey(),
            )));
  }
}

class Body extends StatefulWidget {
  const Body(
      {required Key key,
      required this.searchController,
      required this.listItemsExist,
      required this.isSearching,
      required this.contactsFiltered,
      required this.contacts,
      required this.contactsColorMap,
      required this.phoneNumber,
      required this.userId,
      required this.changeFocusMode,
      required this.isFocusMode})
      : super(key: key);

  final TextEditingController searchController;
  final bool listItemsExist;
  final bool isSearching;
  final List<Contact> contactsFiltered;
  final List<Contact> contacts;
  final Map<String, Color> contactsColorMap;
  final String phoneNumber;
  final String userId;
  final Function(bool) changeFocusMode;
  final bool isFocusMode;
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  // calls/Messages block on focus mode
  String _soundMode = 'Unknown';
  String _permissionStatus = 'Unknown';
  ToggleFocusMode(bool focusMode) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(widget.userId)
        .update({'focusMode': focusMode});
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 1274200 * asin(sqrt(a));
  }

  getCurrentLocationStatus(id, UserLocation current) async {
    print('locations $id');
    print(current.latitude);
    print(current.longitude);
    FirebaseFirestore.instance.collection('user').doc(id).get().then((value) {
      final userDataByID = value.data();
      List<dynamic> focusLocation = userDataByID!['focusLocation'];
      for (var location in focusLocation) {
        double latitude = location['latitude'] ?? 0.0;
        double longitude = location['longitude'] ?? 0.0;

        double distance = calculateDistance(
            latitude, longitude, current.latitude, current.longitude);

        // Check if the distance is within 10 miles
        if (distance >= 16093.4) {
          print('Location is within 10 miles: $latitude, $longitude');
          ToggleFocusMode(true);

          // make phone on silent
          setSilentMode();
        } else {
          print('Location is more than 10 miles away: $latitude, $longitude');
          ToggleFocusMode(false);

          // make phone on normal
          setNormalMode();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print('at body state');
    print(widget.listItemsExist);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserLocation>(builder: (context, userLocation, _) {
      // getCurrentLocationStatus(widget.userId, userLocation);
      return widget.isFocusMode
          ? Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.work,
                      color: Colors.blue,
                      size: 80.0,
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      'Currently in Focus Mode',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 25.0,
                      ),
                    )
                  ],
                ),
              ),
            )
          : Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Container(
                    child: TextField(
                      controller: widget.searchController,
                      decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.blue),
                          labelText: 'Search',
                          border: new OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50.0)),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                              )),
                          prefixIcon: Icon(Icons.search, color: Colors.blue)),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  widget.listItemsExist
                      ? Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.isSearching
                                ? widget.contactsFiltered.length
                                : widget.contacts.length,
                            itemBuilder: (context, index) {
                              Contact contact = widget.isSearching
                                  ? widget.contactsFiltered[index]
                                  : widget.contacts[index];

                              // var baseColor =
                              //     widget.contactsColorMap[contact.displayName]
                              //         as dynamic;

                              // Color color1 = baseColor[800];
                              // Color color2 = baseColor[400];

                              Color color1 = Colors.red;
                              Color color2 = Colors.blue;
                              return GestureDetector(
                                onTap: () {
                                  if (contact.phones?.isNotEmpty == true) {
                                    String receiverNumber = contact
                                        .phones!.first.value
                                        .toString()
                                        .replaceAll(' ', '')
                                        .replaceAll('+91', '');
                                    String senderNumber = widget.phoneNumber;
                                    String receiverName =
                                        contact.displayName.toString();

                                    Navigator.pushNamed(
                                      context,
                                      ChatScreen.id,
                                      arguments: {
                                        'receiver': receiverNumber,
                                        'sender': senderNumber,
                                        'receiverName': receiverName,
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      contact.displayName.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                    subtitle: FutureBuilder(
                                      future: contact.phones?.isEmpty == true
                                          ? Future.value(null)
                                          : FirebaseFirestore.instance
                                              .collection(
                                                widget.phoneNumber.compareTo(
                                                          contact.phones!.first
                                                              .value
                                                              .toString()
                                                              .replaceAll(
                                                                  ' ', '')
                                                              .replaceAll(
                                                                  '+91', ''),
                                                        ) >
                                                        0
                                                    ? contact.phones!
                                                            .elementAt(0)
                                                            .value
                                                            .toString()
                                                            .replaceAll(' ', '')
                                                            .replaceAll(
                                                                '+91', '') +
                                                        widget.phoneNumber
                                                    : widget.phoneNumber +
                                                        contact.phones!
                                                            .elementAt(0)
                                                            .value
                                                            .toString()
                                                            .replaceAll(' ', '')
                                                            .replaceAll(
                                                                '+91', ''),
                                              )
                                              .orderBy('timestamp',
                                                  descending: true)
                                              .limit(1)
                                              .get(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData &&
                                            snapshot.data != null) {
                                          final QuerySnapshot documents =
                                              snapshot.data;

                                          if (documents.docs.isNotEmpty) {
                                            final documentFirst =
                                                documents.docs.first.data()
                                                    as dynamic;
                                            return Text(
                                              documentFirst['text'],
                                              style: TextStyle(
                                                  color: Colors.white60),
                                            );
                                          }
                                        }
                                        return Text(' ');
                                      },
                                    ),
                                    leading: (contact.avatar != null &&
                                            contact.avatar!.length > 0)
                                        ? CircleAvatar(
                                            backgroundImage: MemoryImage(
                                                contact.avatar as dynamic),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  color1,
                                                  color2,
                                                ],
                                                begin: Alignment.bottomLeft,
                                                end: Alignment.topRight,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              radius: 27.0,
                                              child: Text(
                                                contact.initials(),
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor:
                                                  Colors.transparent,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'No Contacts Found',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 25.0,
                                ),
                              ),
                            ],
                          ),
                        )
                ],
              ),
            );
    });
  }
}
