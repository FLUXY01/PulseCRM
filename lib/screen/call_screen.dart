import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../utils/save_call_logs.dart';

class CallScreen extends StatefulWidget {
  final String channelId;
  final String userId;
  final bool isCaller;
  final String callSessionId;

  const CallScreen({
    required this.channelId,
    required this.userId,
    required this.isCaller,
    required this.callSessionId,
    Key? key,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  RTCPeerConnection? _peerConnection;
  bool _joined = false;
  bool _muted = false;
  bool _speakerOn = false;
  bool _loading = true;
  String? _error;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _initCall();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _initCall() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });
      _localRenderer.srcObject = _localStream;

      _peerConnection = await createPeerConnection({});
      for (var track in _localStream!.getTracks()) {
        _peerConnection!.addTrack(track, _localStream!);
      }

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          setState(() {
            _remoteRenderer.srcObject = event.streams[0];
            _joined = true;
            _loading = false;
          });
        }
      };

      setState(() {
        _loading = false;
      });

      // TODO: Implement signaling for offer/answer/ICE exchange
    } catch (e) {
      _showError('Failed to initialize call: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  void _toggleMute() {
    if (!_disposed && _localStream != null) {
      setState(() => _muted = !_muted);
      _localStream!.getAudioTracks()[0].enabled = !_muted;
    }
  }

  void _toggleSpeaker() async {
    if (!_disposed) {
      setState(() => _speakerOn = !_speakerOn);
      await Helper.setSpeakerphoneOn(_speakerOn);
    }
  }

  Future<void> _endCall({required bool wasMissed}) async {
    try {
      await saveCallLog(
        callerId: widget.isCaller ? widget.userId : widget.channelId,
        callerName: '',
        receiverId: widget.isCaller ? widget.channelId : widget.userId,
        receiverName: '',
        isMissed: wasMissed,
        callSessionId: widget.callSessionId,
      );
    } catch (e) {}
    if (mounted) Navigator.pop(context);
  }

  void _showError(String message) {
    if (!_disposed && mounted) {
      setState(() {
        _error = message;
        _loading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _endCall(wasMissed: true);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D5BFF), Color(0xFF46C2CB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFF6D5BFF))),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Call'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
            child: Text(_error!, style: const TextStyle(color: Colors.red))),
      );
    }
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
            'Call',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                color: Colors.white.withOpacity(0.12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _joined ? Icons.call : Icons.wifi_tethering,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _joined ? 'In Call' : 'Connecting...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                            icon: _muted ? Icons.mic_off : Icons.mic,
                            color: _muted ? Colors.redAccent : Colors.white,
                            onTap: _toggleMute,
                          ),
                          const SizedBox(width: 24),
                          _buildControlButton(
                            icon: _speakerOn ? Icons.volume_up : Icons.hearing,
                            color:
                                _speakerOn ? Colors.greenAccent : Colors.white,
                            onTap: _toggleSpeaker,
                          ),
                          const SizedBox(width: 24),
                          _buildControlButton(
                            icon: Icons.call_end,
                            color: Colors.red,
                            onTap: () => _endCall(wasMissed: false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildVideoView(_localRenderer, 'You'),
                  const SizedBox(width: 24),
                  _buildVideoView(_remoteRenderer, 'Remote'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: Ink(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 28),
          onPressed: onTap,
          splashRadius: 32,
        ),
      ),
    );
  }

  Widget _buildVideoView(RTCVideoRenderer renderer, String label) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white54, width: 2),
            borderRadius: BorderRadius.circular(18),
            color: Colors.black26,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: RTCVideoView(renderer, mirror: label == 'You'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
