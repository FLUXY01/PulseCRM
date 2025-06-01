import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class MessageRepository {
  final _messages = FirebaseFirestore.instance.collection('messages');

  Stream<List<Message>> getMessages(String userId, String customerId) {
    return _messages
        .where('senderId', whereIn: [userId, customerId])
        .where('receiverId', whereIn: [userId, customerId])
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  Future<void> sendMessage(Message message) async {
    await _messages.add(message.toMap());
  }
}
