import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_crm/screen/widget/customer_dialog.dart';
import 'package:flutter_crm/screen/widget/filter_sheet.dart';
import '../bloc/customer_bloc.dart';
import '../repository/customer_repository.dart';

class CustomerApp extends StatefulWidget {
  final String role;
  const CustomerApp({Key? key, required this.role}) : super(key: key);

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerBloc(CustomerRepository())..add(LoadCustomers()),
      child: CustomerPage(role: widget.role),
    );
  }
}

class CustomerPage extends StatelessWidget {
  final String role;
  final TextEditingController searchController = TextEditingController();

  CustomerPage({required this.role});

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
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Customers',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 26,
              color: Colors.white,
              letterSpacing: 1.1,
            ),
          ),
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.filter_list, color: Colors.white, size: 28),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => BlocProvider.value(
                    value: context.read<CustomerBloc>(),
                    child: FilterSheet(),
                  ),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search customers...',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    context.read<CustomerBloc>().add(SearchCustomers(value));
                  },
                ),
              ),
            ),
          ),
        ),
        body: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            if (state is CustomerLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6D5BFF)));
            } else if (state is CustomerLoaded) {
              if (state.customers.isEmpty) {
                return const Center(
                  child: Text(
                    'No customers found.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: 18,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.customers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final customer = state.customers[index];
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
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 20),
                      leading: const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFF6D5BFF),
                        child:
                            Icon(Icons.person, color: Colors.white, size: 32),
                      ),
                      title: Text(
                        customer.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (customer.email.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.email,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    customer.email,
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
                          if (customer.phone.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.phone,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    customer.phone,
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
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  customer.isActive ? 'Active' : 'Inactive',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: customer.isActive
                                    ? Color(0xFF46C2CB)
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              customer.isActive
                                  ? Icons.toggle_on
                                  : Icons.toggle_off,
                              color: customer.isActive
                                  ? Colors.greenAccent
                                  : Colors.white38,
                              size: 32,
                            ),
                            onPressed: () {
                              final updated = customer.copyWith(
                                  isActive: !customer.isActive);
                              context
                                  .read<CustomerBloc>()
                                  .add(UpdateCustomer(updated));
                            },
                          ),
                          if (role.toLowerCase() == 'admin') ...[
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.white, size: 26),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<CustomerBloc>(),
                                    child: CustomerDialog(customer: customer),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.white, size: 26),
                              onPressed: () {
                                context
                                    .read<CustomerBloc>()
                                    .add(DeleteCustomer(customer.id));
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return Container();
          },
        ),
        floatingActionButton: role.toLowerCase() == 'admin'
            ? FloatingActionButton(
                backgroundColor: const Color(0xFF6D5BFF),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<CustomerBloc>(),
                      child: const CustomerDialog(),
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}
