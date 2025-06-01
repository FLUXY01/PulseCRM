import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_crm/screen/customer_app.dart';
import 'package:flutter_crm/screen/profile_screen.dart';
import 'package:flutter_crm/screen/widget/bottom_navigation.dart';
import 'package:uuid/uuid.dart';
import 'call_log_screen.dart';
import 'call_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final String role;
  const HomeScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
        CustomerApp(role: widget.role),
        _buildChatTab(),
        _buildCallTab(),
        ProfileScreen(),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setUserPresence(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setUserPresence(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setUserPresence(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _setUserPresence(false);
    }
  }

  Future<void> _setUserPresence(bool isActive) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'isActive': isActive,
        'canCall': isActive,
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildChatTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D5BFF), Color(0xFF46C2CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Card(
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customers')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final customers = snapshot.data!.docs;
                if (customers.isEmpty) {
                  return const Text(
                    'No active customers.',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18,
                      color: Color(0xFF6D5BFF),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: customers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final customer =
                        customers[index].data() as Map<String, dynamic>;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8F7BFF), Color(0xFF46C2CB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ListTile(
                        isThreeLine: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        leading: const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFF46C2CB),
                          child:
                              Icon(Icons.person, color: Colors.white, size: 32),
                        ),
                        title: Text(
                          customer['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (customer['email'] != null)
                              Row(
                                children: [
                                  const Icon(Icons.email,
                                      color: Colors.white70, size: 16),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      customer['email'],
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            if (customer['phone'] != null)
                              Row(
                                children: [
                                  const Icon(Icons.phone,
                                      color: Colors.white70, size: 16),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      customer['phone'],
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Chip(
                                  label: Text(
                                    'Active for chat',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: Color(0xFF6D5BFF),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chat_bubble_outline,
                            color: Colors.lime, size: 32),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                peerId: customers[index].id,
                                peerName: customer['name'] ?? 'No Name',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallTab() {
    final _uuid = Uuid();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D5BFF), Color(0xFF46C2CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CallLogScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8F7BFF), Color(0xFF46C2CB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(
                  top: 24, left: 24, right: 24, bottom: 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Call Logs',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('customers')
                        .where('isActive', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final customers = snapshot.data!.docs;
                      if (customers.isEmpty) {
                        return const Text(
                          'No active customers to call.',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            color: Color(0xFF6D5BFF),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: customers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final customer =
                              customers[index].data() as Map<String, dynamic>;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6D5BFF), Color(0xFF46C2CB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ListTile(
                              isThreeLine: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 20),
                              // No leading
                              title: Text(
                                customer['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontFamily: 'YourCustomFont',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (customer['email'] != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.email,
                                            color: Colors.white70, size: 16),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            customer['email'],
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (customer['phone'] != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.phone,
                                            color: Colors.white70, size: 16),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            customer['phone'],
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 4),
                                  const Row(
                                    children: [
                                      Chip(
                                        label: const Text(
                                          'Active to call',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        backgroundColor: Color(0xFF46C2CB),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const CircleAvatar(
                                radius: 28,
                                backgroundColor: Color(0xFF8F7BFF),
                                child: Icon(Icons.phone,
                                    color: Colors.white, size: 32),
                              ),
                              onTap: () {
                                final sessionId = _uuid.v4();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CallScreen(
                                      channelId: customers[index].id,
                                      userId: FirebaseAuth
                                              .instance.currentUser?.uid ??
                                          '',
                                      isCaller: true,
                                      callSessionId: sessionId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            'Deal Converter',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 28,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
