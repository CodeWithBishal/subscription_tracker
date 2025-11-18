import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/subscription.dart';
import '../../state/providers.dart';
import '../../state/tracker_state.dart';
import '../widgets/sale_form_dialog.dart';
import '../widgets/shimmer_placeholders.dart';
import '../widgets/subscription_payment_sheet.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackerNotifierProvider);
    final notifier = ref.read(trackerNotifierProvider.notifier);
    final padding = MediaQuery.of(context).size.width > 600 ? 32.0 : 16.0;

    final upcoming = state.upcomingRenewals.take(5).toList();
    final recentSales = state.recentSales.take(5).toList();
    final isInitialLoading =
        state.isLoading &&
        state.sales.isEmpty &&
        state.subscriptions.isEmpty &&
        state.customers.isEmpty;

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView(
        padding: EdgeInsets.all(padding),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _Header(state: state, onAddSale: () => showSaleForm(context, ref)),
          const SizedBox(height: 16),
          if (state.isOffline)
            const _InfoBanner(
              icon: Icons.cloud_off,
              message:
                  'Offline mode: showing cached data. Connect to sync updates.',
            ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            _InfoBanner(
              icon: Icons.error_outline,
              message: state.errorMessage!,
              background: Colors.red.shade50,
            ),
          ],
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Upcoming renewals',
            subtitle: 'Next ${upcoming.length} cycles',
            action: upcoming.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: notifier.refresh,
                  ),
          ),
          const SizedBox(height: 8),
          if (isInitialLoading)
            const ShimmerListPlaceholder(count: 3, height: 78)
          else if (upcoming.isEmpty)
            const _PlaceholderCard(
              icon: Icons.calendar_month_outlined,
              message: 'No renewals within the next window.',
            )
          else
            ...upcoming.map(
              (subscription) => _SubscriptionTile(
                subscription: subscription,
                state: state,
                onMarkPaid: () =>
                    showSubscriptionPaymentSheet(context, ref, subscription),
              ),
            ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Recent sales',
            subtitle: '${recentSales.length} latest wins',
          ),
          const SizedBox(height: 8),
          if (isInitialLoading)
            const ShimmerListPlaceholder(count: 3, height: 78)
          else if (recentSales.isEmpty)
            const _PlaceholderCard(
              icon: Icons.receipt_long,
              message: 'Log a sale to get started.',
            )
          else
            ...recentSales.map((sale) {
              final customer = state.customerById(sale.customerId);
              return Card(
                child: ListTile(
                  title: Text(sale.title),
                  subtitle: Text(
                    '${sale.saleDateLabel} · '
                    '${customer?.name ?? 'Unknown customer'}',
                  ),
                  trailing: Text(sale.formattedAmount),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.onAddSale});

  final TrackerState state;
  final VoidCallback onAddSale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                state.lastSyncedAt == null
                    ? 'Syncing…'
                    : 'Synced ${DateFormat('MMM d, hh:mm a').format(state.lastSyncedAt!.toLocal())}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: onAddSale,
          icon: const Icon(Icons.add),
          label: const Text('Add sale'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle, this.action});

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({
    required this.subscription,
    required this.state,
    required this.onMarkPaid,
  });

  final Subscription subscription;
  final TrackerState state;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final sale = state.saleById(subscription.saleId);
    final customer = state.customerById(sale?.customerId ?? '');
    final dueColor = subscription.isOverdue ? Colors.red : Colors.orange;

    return Card(
      child: ListTile(
        leading: Icon(Icons.notifications_active_outlined, color: dueColor),
        title: Text(subscription.serviceName),
        subtitle: Text(
          '${sale?.title ?? 'Unknown sale'} · '
          '${customer?.name ?? 'Unknown customer'}',
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Due ${subscription.dueLabel}'),
            TextButton(onPressed: onMarkPaid, child: const Text('Mark paid')),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.message,
    this.background,
  });

  final IconData icon;
  final String message;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background ?? Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
