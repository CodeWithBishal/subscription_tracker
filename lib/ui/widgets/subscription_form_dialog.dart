import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/billing_cycle.dart';
import '../../models/drafts.dart';
import '../../state/providers.dart';
import 'toast_utils.dart';

Future<void> showSubscriptionForm(
  BuildContext context,
  WidgetRef ref,
  String saleId,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _SubscriptionFormSheet(saleId: saleId, ref: ref),
  );
}

class _SubscriptionFormSheet extends ConsumerStatefulWidget {
  const _SubscriptionFormSheet({required this.saleId, required this.ref});

  final String saleId;
  final WidgetRef ref;

  @override
  ConsumerState<_SubscriptionFormSheet> createState() =>
      _SubscriptionFormSheetState();
}

class _SubscriptionFormSheetState
    extends ConsumerState<_SubscriptionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _serviceController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  BillingCycle _billingCycle = BillingCycle.yearly;
  bool _autoRenew = true;
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 30));
  bool _isSubmitting = false;

  @override
  void dispose() {
    _serviceController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add subscription',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              TextFormField(
                controller: _serviceController,
                decoration: const InputDecoration(labelText: 'Service name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                    ? 'Enter valid amount'
                    : null,
              ),
              DropdownButtonFormField<BillingCycle>(
                initialValue: _billingCycle,
                items: BillingCycle.values
                    .map(
                      (cycle) => DropdownMenuItem<BillingCycle>(
                        value: cycle,
                        child: Text(cycle.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _billingCycle = value ?? _billingCycle),
                decoration: const InputDecoration(labelText: 'Billing cycle'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _autoRenew,
                onChanged: (value) => setState(() => _autoRenew = value),
                title: const Text('Auto renew'),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Next due: '
                      '${_nextDueDate.toLocal().toString().substring(0, 10)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _nextDueDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 1),
                        ),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _nextDueDate = picked);
                      }
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save subscription'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final draft = SubscriptionDraft(
        saleId: widget.saleId,
        serviceName: _serviceController.text.trim(),
        billingCycle: _billingCycle,
        amount: double.parse(_amountController.text),
        nextDueDate: _nextDueDate,
        autoRenew: _autoRenew,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      await ref.read(trackerNotifierProvider.notifier).addSubscription(draft);
      if (!mounted) return;
      Navigator.of(context).pop();
      showSuccessToast(context, 'Subscription added.');
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, 'Failed to save subscription: $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
