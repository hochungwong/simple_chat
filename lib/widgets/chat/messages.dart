import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './message_bubble.dart';

class Messages extends StatelessWidget {
  final currentUserId = FirebaseAuth.instance.currentUser.uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = chatSnapshot.data.documents;
        return ListView.builder(
          reverse: true,
          itemBuilder: (_, index) {
            return MessageBubble(
                message: chatDocs[index]['text'],
                isMe: chatDocs[index]['userId'] == currentUserId,
                userName: chatDocs[index]['username'],
                image: chatDocs[index]['userImage'],
                key: ValueKey(chatDocs[index].documentID));
          },
          itemCount: chatDocs.length,
        );
      },
    );
  }
}
