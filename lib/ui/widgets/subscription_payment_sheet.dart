import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/subscription.dart';
import '../../state/providers.dart';
import 'toast_utils.dart';

Future<void> showSubscriptionPaymentSheet(
  BuildContext context,
  WidgetRef ref,
  Subscription subscription,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) =>
        _SubscriptionPaymentSheet(subscription: subscription, ref: ref),
  );
}

class _SubscriptionPaymentSheet extends ConsumerStatefulWidget {
  const _SubscriptionPaymentSheet({
    required this.subscription,
    required this.ref,
  });

  final Subscription subscription;
  final WidgetRef ref;

  @override
  ConsumerState<_SubscriptionPaymentSheet> createState() =>
      _SubscriptionPaymentSheetState();
}

class _SubscriptionPaymentSheetState
    extends ConsumerState<_SubscriptionPaymentSheet> {
  late DateTime _paidOn;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _paidOn = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final subscription = widget.subscription;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Record payment',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text('${subscription.serviceName} · Due ${subscription.dueLabel}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Paid on ${_paidOn.toLocal().toString().substring(0, 10)}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _paidOn,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _paidOn = picked);
                    }
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _recordPayment,
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Mark as paid'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordPayment() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(trackerNotifierProvider.notifier)
          .markSubscriptionPaid(widget.subscription.id, _paidOn);
      if (!mounted) return;
      Navigator.of(context).pop();
      showSuccessToast(context, 'Subscription updated.');
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, 'Unable to update: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
