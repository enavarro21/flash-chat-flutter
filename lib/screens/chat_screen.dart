import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flash_chat/constants.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Create instance of cloud Firestore
  final _firestore = Firestore.instance;

  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;

  // Saved text from user
  String messageText;

  @override
  void initState() {
    super.initState();

    // Ensures user is authenticated and signed in properly
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        // print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // // Get list of messages from Firebase Cloud Store database, when called
  // // Single instance of, when grabbed, similar to Future
  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').getDocuments();
  //   for (var message in messages.documents) {
  //     print(message.data);
  //   }
  // }

  // Used to listen to a stream of data when database is updated
  void messagesStream() async {
    // Subscribes and listens to the snapshots streams
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.documents) {
        print(message.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Show messages from database using StreamBuilder
            // Returns a list of Text Widgets.
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              // Widget that builder returns is the Column of Text Widgets
              builder: (context, snapshot) {
                // snapshot == Flutter's async snapshot(contains QuerySnapshot)
                // If no Data in chat yet, display indicator
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                // This snapshot now contains Firebase's QuerySnapshot, which
                // in turn contains a list of document snapshots
                final messages = snapshot.data.documents;
                // Build a List of Text Widgets
                List<Text> messageWidgets = [];
                for (var message in messages) {
                  // message is a Document snapshot from Firebase
                  final messageText = message.data['text'];
                  final messageSender = message.data['sender'];
                  // Create message Widget
                  final messageWidget =
                      Text('$messageText from $messageSender');
                  // Add messageWidget to the list of messageWidgets
                  messageWidgets.add(messageWidget);
                }
                return Column(
                  children: messageWidgets,
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      //Using loggedInUser + messageText
                      // .add method expects a map{} datatype
                      // Add messages to Cloud Firestore database
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
