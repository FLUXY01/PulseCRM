import 'package:flutter/material.dart';
import '../repository/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name;
  String? _email;
  String? _role;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final repo = UserRepository();
      final data = await repo.getCurrentUserProfile();
      print('Fetched user data: $data'); // Debug print
      setState(() {
        _name = data?['name'] ?? '';
        _email = data?['email'] ?? '';
        _role = (data?['role'] as String?)?.trim();
        if (_role == null || _role!.isEmpty) _role = 'Agent';
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load profile';
      });
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
      ),
      centerTitle: false,
    );

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6D5BFF)),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
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
        appBar: appBar,
        body: Center(
          child: Card(
            elevation: 18,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8F7BFF), Color(0xFF46C2CB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.all(Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF6D5BFF),
                    child: Icon(Icons.person, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _name ?? '',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email, color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _email ?? '',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(
                      _role != null
                          ? (_role![0].toUpperCase() +
                              _role!.substring(1).toLowerCase())
                          : 'Agent',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    backgroundColor: const Color(0xFF46C2CB),
                    avatar: Icon(
                      _role?.toLowerCase() == 'admin'
                          ? Icons.admin_panel_settings
                          : Icons.verified_user,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D5BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 6,
                      ),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: _logout,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
