import '../utils/save_call_logs.dart';

class CallService {
  Future<void> endCall({
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required bool wasMissed,
  }) async {
    try {
      await saveCallLog(
        callerId: callerId,
        callerName: callerName,
        receiverId: receiverId,
        receiverName: receiverName,
        isMissed: wasMissed,
      );
    } catch (e) {
      print('Error ending call: $e');
      // Optionally handle error in UI
    }
  }
}
