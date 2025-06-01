import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';
import '../utils/hive_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CustomerRepository {
  final String boxName = 'customers';
  final CollectionReference _customers =
      FirebaseFirestore.instance.collection('customers');

  Future<List<Customer>> loadCustomers() async {
    final connectivity = await Connectivity().checkConnectivity();
    final box = await getSafeBox<Customer>(boxName);

    if (connectivity == ConnectivityResult.none) {
      return box.values.toList();
    } else {
      final snapshot =
          await FirebaseFirestore.instance.collection('customers').get();
      final customers =
          snapshot.docs.map((doc) => Customer.fromJson(doc.data())).toList();
      await box.clear();
      for (var customer in customers) {
        await box.put(customer.id, customer);
      }
      return customers;
    }
  }

  Future<void> saveCustomers(List<Customer> customers) async {
    final box = await getSafeBox<Customer>(boxName);
    await box.clear();
    for (var customer in customers) {
      await box.put(customer.id, customer);
    }
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      final batch = FirebaseFirestore.instance.batch();
      final collection = FirebaseFirestore.instance.collection('customers');
      for (var customer in customers) {
        batch.set(collection.doc(customer.id), customer.toJson());
      }
      await batch.commit();
    }
  }

  Future<String> getCustomerNameById(String customerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .get();
    final data = doc.data();
    if (data == null || data['name'] == null) {
      // Return 'Unknown' instead of throwing an exception
      return 'Unknown';
    }
    return data['name'] as String;
  }

  Future<void> addCustomer(Customer customer) async {
    await FirebaseFirestore.instance
        .collection('customers')
        .doc(customer.id)
        .set(customer.toMap());
  }

  Future<List<Customer>> fetchCustomers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('customers').get();
    return snapshot.docs.map((doc) => Customer.fromMap(doc.data())).toList();
  }

  Future<void> deleteCustomer(String id) async {
    // Example for Firestore
    await FirebaseFirestore.instance.collection('customers').doc(id).delete();
  }
}
