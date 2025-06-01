import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_log.dart';

class CallLogRepository {
  final CollectionReference _callLogs =
      FirebaseFirestore.instance.collection('call_log');
  final List<CallLog> _localLogs = [];

  Future<void> addCallLog(CallLog log) async {
    await _callLogs.doc(log.callSessionId).set(log.toMap());
    _localLogs.removeWhere((l) => l.callSessionId == log.callSessionId);
    _localLogs.add(log);
  }

  Future<List<CallLog>> fetchCallLogsForUser(String userId) async {
    final query = await _callLogs
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .get();

    final logs = query.docs
        .map((doc) => CallLog.fromMap(doc.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  Stream<List<CallLog>> getUserCallLogs(String userId) {
    final stream = _callLogs
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return stream.map((snapshot) {
      final logs = snapshot.docs
          .map((doc) => CallLog.fromMap(doc.data() as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    });
  }

  Future<void> deleteCallLogById(String callSessionId) async {
    await _callLogs.doc(callSessionId).delete();
    _localLogs.removeWhere((log) => log.callSessionId == callSessionId);
  }

  List<CallLog> getLocalLogs() {
    return List.unmodifiable(_localLogs);
  }
}
