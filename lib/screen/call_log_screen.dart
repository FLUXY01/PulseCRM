import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/call_log_repository.dart';
import '../repository/user_repository.dart';
import '../repository/customer_repository.dart';
import '../models/call_log.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({Key? key}) : super(key: key);

  @override
  State<CallLogScreen> createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  bool _isOnline = true;
  final _userRepository = UserRepository();
  final _customerRepository = CustomerRepository();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    final callLogRepository = RepositoryProvider.of<CallLogRepository>(context);
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D5BFF), Color(0xFF46C2CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Call Logs',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 24,
              color: Colors.white,
              letterSpacing: 1.1,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _isOnline && user != null
            ? StreamBuilder<List<CallLog>>(
                stream: callLogRepository.getUserCallLogs(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildError(snapshot.error);
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6D5BFF)));
                  }
                  final logs = _deduplicateBySessionId(snapshot.data!);
                  if (logs.isEmpty) return _buildNoLogsMessage();
                  return _buildList(logs, callLogRepository);
                },
              )
            : _buildList(
                _deduplicateBySessionId(callLogRepository.getLocalLogs()),
                callLogRepository,
              ),
      ),
    );
  }

  List<CallLog> _deduplicateBySessionId(List<CallLog> logs) {
    final Map<String, CallLog> uniqueLogs = {};
    for (var log in logs) {
      final sessionId = log.callSessionId;
      if (!uniqueLogs.containsKey(sessionId) ||
          log.timestamp.isAfter(uniqueLogs[sessionId]!.timestamp)) {
        uniqueLogs[sessionId] = log;
      }
    }
    final deduped = uniqueLogs.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return deduped;
  }

  Widget _buildNoLogsMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.call, size: 48, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No call logs yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Your recent calls will appear here once you start connecting with customers.',
              style: TextStyle(fontSize: 15, color: Colors.white60),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'Failed to load call logs.\n${error.toString()}',
          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildList(List<CallLog> logs, CallLogRepository repository) {
    if (logs.isEmpty) {
      return _buildNoLogsMessage();
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return FutureBuilder<Map<String, String>>(
          future: _resolveNames(log),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildLoadingCard();
            }
            final names = snapshot.data!;
            if (names['caller'] == 'Unknown' ||
                names['receiver'] == 'Unknown') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                repository.deleteCallLogById(log.id);
              });
              return const SizedBox.shrink();
            }
            return Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white.withOpacity(0.13),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      log.isMissed ? Colors.redAccent : const Color(0xFF46C2CB),
                  child: Icon(
                    log.isMissed ? Icons.call_missed : Icons.call,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  '${names['caller']} → ${names['receiver']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                subtitle: Text(
                  '${_formatTimestamp(log.timestamp)}  |  ${log.isMissed ? 'Missed' : 'Completed'}',
                  style: TextStyle(
                    color: log.isMissed ? Colors.redAccent : Colors.white70,
                    fontFamily: 'Poppins',
                  ),
                ),
                trailing: Icon(
                  log.isMissed
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  color: log.isMissed ? Colors.redAccent : Colors.greenAccent,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.10),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: const ListTile(
        leading: CircleAvatar(backgroundColor: Colors.white24),
        title: Text('Loading...', style: TextStyle(color: Colors.white70)),
        subtitle: Text('Fetching call details...',
            style: TextStyle(color: Colors.white38)),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    // You can use intl package for better formatting
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Future<Map<String, String>> _resolveNames(CallLog log) async {
    String callerName = 'Unknown';
    String receiverName = 'Unknown';

    try {
      callerName = await _userRepository.getUserNameById(log.callerId);
    } catch (_) {
      try {
        callerName =
            await _customerRepository.getCustomerNameById(log.callerId);
      } catch (_) {}
    }

    try {
      receiverName = await _userRepository.getUserNameById(log.receiverId);
    } catch (_) {
      try {
        receiverName =
            await _customerRepository.getCustomerNameById(log.receiverId);
      } catch (_) {}
    }

    return {'caller': callerName, 'receiver': receiverName};
  }
}
