// ignore_for_file: prefer_const_constructors, unnecessary_const

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusaro_clone/src/config/constants.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  final String username = '';

  const ChatScreen({super.key});
  // ChatScreen({required this.username})
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageText = '';
  final _auth = FirebaseAuth.instance;
  final _messageTextController = TextEditingController();

  bool isFocusMode = false;

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.phoneNumber);
      }
    } catch (e) {
      print(e);
    }
    print(loggedInUser.phoneNumber);
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map userInfo = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
        body: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userInfo['recieverName'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23.0,
              ),
            ),
            FutureBuilder(
              future: _firestore
                  .collection('user')
                  .where('phoneNumber', isEqualTo: userInfo['reciever'])
                  .get(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                final QuerySnapshot documents = snapshot.data;
                dynamic firstDocumentData = documents.docs.first.data();
                if (snapshot.hasData) {
                  isFocusMode = firstDocumentData['focusMode'];
                  return firstDocumentData['focusMode']
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Focus Mode',
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 15.0),
                            ),
                            Text(
                              '(Messages Sent are Delayed)',
                              style: TextStyle(fontSize: 13.0),
                            ),
                          ],
                        )
                      : const Text(
                          'Online',
                          style: TextStyle(color: Colors.white70),
                        );
                }
                return const Text(' ');
              },
            ),
          ],
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(
              userInfo: userInfo,
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      enabled: !isFocusMode,
                      controller: _messageTextController,
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      if (_messageTextController.text.isNotEmpty) {
                        //Implement send functionality.
                        _firestore
                            .collection(userInfo['sender']
                                        .compareTo(userInfo['reciever']) >
                                    0
                                ? userInfo['reciever'] + userInfo['sender']
                                : userInfo['sender'] + userInfo['reciever'])
                            .add({
                          'text': _messageTextController.text,
                          'sender': userInfo['sender'],
                          'reciever': userInfo['reciever'],
                          'timestamp': FieldValue.serverTimestamp()
                        });

                        // clear the text field after sending the message
                        _messageTextController.clear();
                      } else {
                        // make scaffold messenger
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a message to send'),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle.copyWith(
                          color: Colors.lightBlueAccent[100]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

/* Message Stream Widget */

// ignore: must_be_immutable
class MessageStream extends StatelessWidget {
  late Map userInfo;
  MessageStream({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection(userInfo['sender'].compareTo(userInfo['reciever']) > 0
                ? userInfo['reciever'] + userInfo['sender']
                : userInfo['sender'] + userInfo['reciever'])
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print(snapshot.data);
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }

          final messages = snapshot.data!.docs.reversed;
          List<Widget> messageWidgets = [];

          for (var message in messages) {
            final messageText = (message.data() as dynamic)['text'];
            final messageSender = (message.data() as dynamic)['sender'];

            final messageBubbleWidget = MessageBubble(
                messageText: messageText,
                messageSender: messageSender,
                isMe: userInfo['sender'] == messageSender);
            messageWidgets.add(messageBubbleWidget);
          }

          return Expanded(
            child: ListView(
              reverse: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageWidgets,
            ),
          );
        });
  }
}

/* Message Bubble Widget */

// ignore: must_be_immutable
class MessageBubble extends StatelessWidget {
  late String messageText, messageSender;
  late bool isMe;
  MessageBubble(
      {super.key,
      required this.messageText,
      required this.messageSender,
      required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            elevation: 5.0,
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageText,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
