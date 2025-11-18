import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sale.dart';
import '../../models/subscription.dart';
import '../../state/providers.dart';
import '../widgets/subscription_form_dialog.dart';
import '../widgets/subscription_payment_sheet.dart';

class SaleDetailSheet extends ConsumerWidget {
  const SaleDetailSheet({super.key, required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackerNotifierProvider);
    final subscriptions = state.subscriptionsForSale(sale.id)
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    final customer = state.customerById(sale.customerId);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${sale.saleDateLabel} · ${customer?.name ?? 'Unknown customer'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Deal value: ${sale.formattedAmount}'),
            if (sale.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(sale.description!),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subscriptions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: state.isOffline
                      ? null
                      : () => showSubscriptionForm(context, ref, sale.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (subscriptions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No subscriptions yet.'),
              )
            else
              ...subscriptions.map(
                (sub) => _SubscriptionRow(
                  subscription: sub,
                  onMarkPaid: () =>
                      showSubscriptionPaymentSheet(context, ref, sub),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionRow extends StatelessWidget {
  const _SubscriptionRow({
    required this.subscription,
    required this.onMarkPaid,
  });

  final Subscription subscription;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(subscription.serviceName),
        subtitle: Text(
          'Due ${subscription.dueLabel} · '
          '${subscription.billingCycle.name} · ₹${subscription.amount.toStringAsFixed(0)}',
        ),
        trailing: TextButton(onPressed: onMarkPaid, child: const Text('Paid')),
      ),
    );
  }
}
