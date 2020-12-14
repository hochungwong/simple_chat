import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets//chat/messages.dart';
import '../widgets//chat/new_message.dart';

const DOCS_PATH = 'chats/FY1ceXj3EtXqpgXW0h40/messages';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _onPress() {
      FirebaseFirestore.instance
          .collection(DOCS_PATH)
          .add({'text': 'This was added by floating action button'});
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('SimpleChat'),
          actions: [
            DropdownButton(
              items: [
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Logout')
                      ],
                    ),
                  ),
                  value: 'logout',
                )
              ],
              onChanged: (itemIdentifier) {
                if (itemIdentifier == 'logout') {
                  FirebaseAuth.instance.signOut();
                }
              },
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).primaryIconTheme.color,
              ),
            )
          ],
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(child: Messages()),
              NewMessage(),
            ],
          ),
        ),
      ),
    );
  }
}
