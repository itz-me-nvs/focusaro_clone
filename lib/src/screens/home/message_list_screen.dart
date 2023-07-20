// ignore_for_file: unnecessary_const, prefer_const_constructors, sort_child_properties_last, unnecessary_new

import 'dart:math' show cos, sqrt, asin;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focusaro_clone/src/screens/home/chat_screen.dart';
import 'package:focusaro_clone/src/screens/home/location_screen.dart';
import 'package:focusaro_clone/src/utils/services/location_services.dart';
import 'package:focusaro_clone/src/utils/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageListScreen extends StatefulWidget {
  static const String id = 'home_screen';
  final String phoneNumber = '9961542144';
  final String userID = 'mINhLg007Rc964sto22qNgibQJ92';
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
    scheduleNotification();
  }

  scheduleNotification() {
    NotificationService.scheduleNotification(19, 18, handleScheduledAction);
  }

  void handleScheduledAction() {
    // Perform your desired action here when the scheduled time has exceeded
    print('Performing action...');
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
          .where('phoneNumber', isEqualTo: '9961542144')
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
    bool isSearching = searchController.text.isNotEmpty;

    return Scaffold(
        backgroundColor: focusMode ? Colors.black : Colors.white,
        floatingActionButton: focusMode
            ? null
            : FloatingActionButton(
                child: const Icon(Icons.location_on),
                onPressed: () {
                  Navigator.pushNamed(context, LocationScreen.id,
                      arguments: {'userID': widget.userID});
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
                    // print(value);
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
        body: Body(
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
        ));

    //   body: StreamProvider<UserLocation>(
    //       create: (context) => LocationService().locationStream,
    //       initialData:
    //           UserLocation(latitude: 0.0, longitude: 0.0, focus: false),
    // );
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
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 1274200 * asin(sqrt(a));
  }

  getdata(id, UserLocation current) async {
    print('locations');
    print(current.latitude);
    print(current.longitude);
    FirebaseFirestore.instance.collection('user').doc(id).get().then((value) {
      final userDataByID = value.data();
      List<dynamic> focusLocation = userDataByID!['focusLocation'];
      print('focusLocation' + focusLocation.toString());

      double result = calculateDistance(focusLocation[0], focusLocation[1],
          current.latitude, current.longitude);
      if (result < 50) {
        widget.changeFocusMode(true);
      } else {
        widget.changeFocusMode(false);
        FirebaseFirestore.instance.collection('user').doc(id).update({
          'focusLocation': [0, 0],
          'focusMode': false,
        });
        // setState(() {
        //   focusMode = true;
        // });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print('at body state');
    print(widget.listItemsExist);
    // getdata(widget.userId, widget.current);
  }

  @override
  Widget build(BuildContext context) {
    // var userLocation = Provider.of<UserLocation>(context);
    // print(userLocation.latitude.toString() + 'Bello');
    // getdata(super.widget.userId, userLocation);
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
                                Navigator.pushNamed(context, ChatScreen.id,
                                    arguments: {
                                      'reciever': contact.phones?.first.value
                                          .toString()
                                          .replaceAll(' ', '')
                                          .replaceAll('+91', ''),
                                      'sender': widget.phoneNumber,
                                      'recieverName': contact.displayName,
                                    });
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                decoration: const BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25))),
                                child: ListTile(
                                    title: Text(
                                      contact.displayName.toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                    ),
                                    subtitle: FutureBuilder(
                                      future: FirebaseFirestore.instance
                                          .collection(widget.phoneNumber
                                                      .compareTo(
                                                    contact.phones!.first.value
                                                        .toString()
                                                        .replaceAll(' ', '')
                                                        .replaceAll('+91', ''),
                                                  ) >
                                                  0
                                              ? contact.phones!
                                                      .elementAt(0)
                                                      .value
                                                      .toString()
                                                      .replaceAll(' ', '')
                                                      .replaceAll('+91', '') +
                                                  widget.phoneNumber
                                              : widget.phoneNumber +
                                                  contact.phones!
                                                      .elementAt(0)
                                                      .value
                                                      .toString()
                                                      .replaceAll(' ', '')
                                                      .replaceAll('+91', ''))
                                          .orderBy('timestamp',
                                              descending: true)
                                          .limit(1)
                                          .get(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.hasData) {
                                          final QuerySnapshot documents =
                                              snapshot.data;

                                          final documentFirst =
                                              documents.docs.first.data()
                                                  as dynamic;

                                          return Text(
                                            documentFirst['text'],
                                            style: TextStyle(
                                                color: Colors.white60),
                                          );
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
                                                    end: Alignment.topRight)),
                                            child: CircleAvatar(
                                                radius: 27.0,
                                                child: Text(contact.initials(),
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                backgroundColor:
                                                    Colors.transparent))),
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
  }
}
