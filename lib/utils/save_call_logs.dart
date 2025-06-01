import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../repository/call_log_repository.dart';
import '../repository/user_repository.dart';
import '../repository/customer_repository.dart';
import '../models/call_log.dart';
import 'package:flutter/material.dart';

final _callLogRepository = CallLogRepository();
final _userRepository = UserRepository();
final _customerRepository = CustomerRepository();
final _uuid = Uuid();

Future<String> _resolveName(String id) async {
  try {
    return await _userRepository.getUserNameById(id);
  } catch (_) {
    try {
      return await _customerRepository.getCustomerNameById(id);
    } catch (_) {
      return 'Unknown';
    }
  }
}

Future<void> saveCallLog({
  required String callerId,
  required String callerName,
  required String receiverId,
  required String receiverName,
  required bool isMissed,
  String? callSessionId,
}) async {
  final sessionId = callSessionId ?? _uuid.v4();
  final resolvedCallerName =
      callerName.isNotEmpty ? callerName : await _resolveName(callerId);
  final resolvedReceiverName =
      receiverName.isNotEmpty ? receiverName : await _resolveName(receiverId);

  if (resolvedCallerName == 'Unknown' || resolvedReceiverName == 'Unknown') {
    debugPrint('Not saving call log: caller or receiver name unknown');
    return;
  }
  final existing = await FirebaseFirestore.instance
      .collection('call_log')
      .doc(sessionId)
      .get();
  if (existing.exists) {
    debugPrint(
        'Call log for session $sessionId already exists. Skipping save.');
    return;
  }

  final log = CallLog(
    id: sessionId,
    callSessionId: sessionId,
    callerId: callerId,
    callerName: resolvedCallerName,
    receiverId: receiverId,
    receiverName: resolvedReceiverName,
    timestamp: DateTime.now(),
    isMissed: isMissed,
    participants: [callerId, receiverId],
  );
  await _callLogRepository.addCallLog(log);
}
