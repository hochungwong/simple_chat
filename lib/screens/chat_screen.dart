import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const DOCS_PATH = 'chats/FY1ceXj3EtXqpgXW0h40/messages';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _onPress() {
      FirebaseFirestore.instance
          .collection(DOCS_PATH)
          .add({'text': 'This was added by floating action button'});
    }

    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection(DOCS_PATH).snapshots(),
          builder: (ctx, streamSnapShot) {
            if (streamSnapShot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final documents = streamSnapShot.data.documents;
            return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (ctx, index) => Container(
                      padding: EdgeInsets.all(8),
                      child: Text(documents[index]['text']),
                    ));
          }),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: _onPress),
    );
  }
}
