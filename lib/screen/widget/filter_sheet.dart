import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/customer_bloc.dart';

class FilterSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D5BFF), Color(0xFF46C2CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              _buildTile(
                context,
                icon: Icons.check_circle,
                label: 'Active',
                color: Colors.greenAccent,
                onTap: () {
                  context.read<CustomerBloc>().add(FilterCustomers(true));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _buildTile(
                context,
                icon: Icons.remove_circle,
                label: 'Inactive',
                color: Colors.redAccent,
                onTap: () {
                  context.read<CustomerBloc>().add(FilterCustomers(false));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _buildTile(
                context,
                icon: Icons.list_alt,
                label: 'All',
                color: Colors.white,
                onTap: () {
                  context.read<CustomerBloc>().add(LoadCustomers());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      elevation: 6,
      color: Colors.white.withOpacity(0.13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        onTap: onTap,
        splashColor: color.withOpacity(0.2),
      ),
    );
  }
}
