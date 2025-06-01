import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_crm/repository/customer_repository.dart';
import 'package:flutter_crm/repository/call_log_repository.dart';
import 'package:flutter_crm/screen/signup_screen.dart';
import 'package:flutter_crm/screen/home_screen.dart';
import 'package:flutter_crm/utils/hive_utils.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'bloc/customer_bloc.dart';
import 'models/customer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(CustomerAdapter());
  await getSafeBox<Customer>('customers');
  final customerRepository = CustomerRepository();

  runApp(
    RepositoryProvider<CallLogRepository>(
      create: (_) => CallLogRepository(),
      child: BlocProvider(
        create: (_) => CustomerBloc(customerRepository),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        '/signup': (context) => SignupScreen(),
        '/home': (context) =>
            HomeScreen(role: ''), // fallback, not used directly
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> _getUserRole(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    return (data?['role'] as String?)?.trim();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in, fetch role
          return FutureBuilder<String?>(
            future: _getUserRole(snapshot.data!.uid),
            builder: (context, roleSnap) {
              if (roleSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (roleSnap.hasError || roleSnap.data == null) {
                // No Firestore user document, sign out and show signup
                FirebaseAuth.instance.signOut();
                return SignupScreen();
              }
              final role = (roleSnap.data == null || roleSnap.data!.isEmpty)
                  ? 'Agent'
                  : roleSnap.data!;
              return HomeScreen(role: role);
            },
          );
        } else {
          // Not signed in
          return SignupScreen();
        }
      },
    );
  }
}
