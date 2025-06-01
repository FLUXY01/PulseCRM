import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;
      final doc = await _users.doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> updateCurrentUserProfile(Map<String, dynamic> data) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('No user');
      await _users.doc(uid).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<String> getUserNameById(String userId) async {
    final doc = await _users.doc(userId).get();
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null || data['name'] == null) {
      throw Exception('User name not found for userId: $userId');
    }
    return data['name'] as String;
  }
}
