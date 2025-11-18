import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sale.dart';
import '../../state/providers.dart';
import '../widgets/sale_form_dialog.dart';
import '../widgets/shimmer_placeholders.dart';
import 'sale_detail_sheet.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
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
    final sales = state.sales.where((sale) {
      final customer = state.customerById(sale.customerId);
      if (query.isEmpty) return true;
      return sale.matchesQuery(query, customerName: customer?.name ?? '');
    }).toList()..sort((a, b) => b.saleDate.compareTo(a.saleDate));
    final isLoading = state.isLoading && state.sales.isEmpty;

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
                    hintText: 'Search sales or customers',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => showSaleForm(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Sale'),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ShimmerListPlaceholder(count: 6, height: 80),
                )
              : sales.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    final customer = state.customerById(sale.customerId);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(sale.title),
                        subtitle: Text(
                          '${sale.saleDateLabel} · '
                          '${customer?.name ?? 'Unknown customer'}',
                        ),
                        trailing: Text(sale.formattedAmount),
                        onTap: () => _openSaleDetail(sale),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _openSaleDetail(Sale sale) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SaleDetailSheet(sale: sale),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'No sales yet. Log your first sale to populate the dashboard.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
