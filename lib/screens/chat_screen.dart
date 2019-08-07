import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flash_chat/constants.dart';

// Create instance of cloud Firestore
final _firestore = Firestore.instance;
// Allow access to loggedInUser in file
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;

  // Create a Text Editing Controller for clearing text
  final messageTextController = TextEditingController();

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

  // // Used to listen to a stream of data when database is updated
  // void messagesStream() async {
  //   // Subscribes and listens to the snapshots streams
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     for (var message in snapshot.documents) {
  //       print(message.data);
  //     }
  //   }
  // }

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
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      // Can use this to control what is displayed in Text field
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      // Can tell the TextEditingController to clear field
                      messageTextController.clear();
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

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
        final messages = snapshot.data.documents.reversed;
        // Build a List of Text Widgets
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          // message is a Document snapshot from Firebase
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];

          // Alternate display of the loggedInUser's message
          final currentUser = loggedInUser.email;

          // Create message Widget
          final messageBubble = MessageBubble(
              sender: messageSender,
              text: messageText,
              // True/False depending on if it is the currentUser
              isMe: currentUser == messageSender);
          // Add messageWidget to the list of messageWidgets
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 20.0,
            ),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(sender,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black54,
              )),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
