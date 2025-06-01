// lib/models/call_log.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CallLog {
  final String id;
  final String callSessionId;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final DateTime timestamp;
  final bool isMissed;
  final List<String> participants;

  CallLog({
    required this.id,
    required this.callSessionId,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.timestamp,
    required this.isMissed,
    required this.participants,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'callSessionId': callSessionId,
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'timestamp': Timestamp.fromDate(timestamp),
      'isMissed': isMissed,
      'participants': participants,
    };
  }

  factory CallLog.fromMap(Map<String, dynamic> map) => CallLog(
        id: map['id'],
        callSessionId: map['callSessionId'],
        callerId: map['callerId'],
        callerName: map['callerName'],
        receiverId: map['receiverId'],
        receiverName: map['receiverName'],
        timestamp: map['timestamp'] is Timestamp
            ? (map['timestamp'] as Timestamp).toDate()
            : DateTime.parse(map['timestamp']),
        isMissed: map['isMissed'],
        participants: List<String>.from(map['participants'] ?? []),
      );
}
