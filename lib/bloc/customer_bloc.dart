import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/customer.dart';
import 'package:equatable/equatable.dart';
import '../repository/customer_repository.dart';
import '../utils/hive_utils.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository repository;
  List<Customer> _allCustomers = [];

  CustomerBloc(this.repository) : super(CustomerLoading()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<SearchCustomers>(_onSearchCustomers);
    on<FilterCustomers>(_onFilterCustomers);
  }

  Future<void> _onLoadCustomers(
      LoadCustomers event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      final customers = await repository.loadCustomers();
      _allCustomers = customers;
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError('Failed to load customers: $e'));
    }
  }

  Future<void> _onAddCustomer(
      AddCustomer event, Emitter<CustomerState> emit) async {
    final box = await getSafeBox<Customer>('customers');
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(event.customer.id)
          .set(event.customer.toJson());
    }
    await box.put(event.customer.id, event.customer);

    // Fetch the latest customers and update _allCustomers
    List<Customer> customers;
    if (connectivity != ConnectivityResult.none) {
      final snapshot =
          await FirebaseFirestore.instance.collection('customers').get();
      customers =
          snapshot.docs.map((doc) => Customer.fromJson(doc.data())).toList();
      await box.clear();
      for (var customer in customers) {
        await box.put(customer.id, customer);
      }
    } else {
      customers = box.values.toList();
    }
    _allCustomers = customers;
    emit(CustomerLoaded(customers));
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomer event, Emitter<CustomerState> emit) async {
    // Update in _allCustomers
    _allCustomers = _allCustomers
        .map((c) => c.id == event.customer.id ? event.customer : c)
        .toList();
    await repository.saveCustomers(_allCustomers);
    emit(CustomerLoaded(_allCustomers));
  }

  Future<void> _onDeleteCustomer(
      DeleteCustomer event, Emitter<CustomerState> emit) async {
    final box = await getSafeBox<Customer>('customers');
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(event.id)
          .delete();
    }
    await box.delete(event.id);

    _allCustomers = _allCustomers.where((c) => c.id != event.id).toList();
    await repository.saveCustomers(_allCustomers);
    emit(CustomerLoaded(_allCustomers));
  }

  void _onSearchCustomers(SearchCustomers event, Emitter<CustomerState> emit) {
    final query = event.query.trim().toLowerCase();
    if (query.isEmpty) {
      emit(CustomerLoaded(_allCustomers));
    } else {
      final filtered = _allCustomers
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.email.toLowerCase().contains(query) ||
              c.phone.contains(query))
          .toList();
      emit(CustomerLoaded(filtered));
    }
  }

  void _onFilterCustomers(FilterCustomers event, Emitter<CustomerState> emit) {
    final filtered =
        _allCustomers.where((c) => c.isActive == event.isActive).toList();
    emit(CustomerLoaded(filtered));
  }
}
