import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../widgets/customer_form_dialog.dart';
import '../widgets/shimmer_placeholders.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackerNotifierProvider);
    final query = _searchController.text.toLowerCase();
    final customers = state.customers.where((customer) {
      if (query.isEmpty) return true;
      return customer.searchableText.contains(query);
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
    final isLoading = state.isLoading && state.customers.isEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by name, phone, email',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => showCustomerForm(context, ref),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Customer'),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ShimmerListPlaceholder(count: 6, height: 74),
                )
              : customers.isEmpty
              ? const _EmptyCustomers()
              : ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            customer.initials.isEmpty
                                ? '?'
                                : customer.initials.toUpperCase(),
                          ),
                        ),
                        title: Text(customer.name),
                        subtitle: Text('${customer.email}\n${customer.phone}'),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyCustomers extends StatelessWidget {
  const _EmptyCustomers();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'No customers yet. Add your first customer to begin tracking.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ),
    );
  }
}
