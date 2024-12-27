import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final DocumentReference sender;
  final DocumentReference receiver;
  final String message;
  final DateTime timestamp;

  Chat({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.message,
    required this.timestamp,
  });

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      id: doc.id,
      sender: data['sender'] as DocumentReference,
      receiver: data['receiver'] as DocumentReference,
      message: data['message'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}