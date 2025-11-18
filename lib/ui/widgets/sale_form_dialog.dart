import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/drafts.dart';
import '../../state/providers.dart';
import 'toast_utils.dart';

Future<void> showSaleForm(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _SaleFormSheet(ref: ref),
  );
}

class _SaleFormSheet extends ConsumerStatefulWidget {
  const _SaleFormSheet({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_SaleFormSheet> createState() => _SaleFormSheetState();
}

class _SaleFormSheetState extends ConsumerState<_SaleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _customerId;
  DateTime _saleDate = DateTime.now();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackerNotifierProvider);
    final customers = state.customers;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log a sale',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (customers.isEmpty)
                const Text(
                  'Add a customer first from the Customers tab.',
                  style: TextStyle(color: Colors.redAccent),
                ),
              DropdownButtonFormField<String>(
                items: customers
                    .map(
                      (customer) => DropdownMenuItem<String>(
                        value: customer.id,
                        child: Text(customer.shortDescription),
                      ),
                    )
                    .toList(),
                onChanged: customers.isEmpty
                    ? null
                    : (value) => setState(() => _customerId = value),
                decoration: const InputDecoration(labelText: 'Customer'),
                validator: (value) =>
                    value == null ? 'Please pick a customer' : null,
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Sale title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Deal value (₹)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                    ? 'Enter amount'
                    : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sale date: '
                      '${_saleDate.toLocal().toString().substring(0, 10)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _saleDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _saleDate = picked);
                      }
                    },
                    child: const Text('Pick date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting || customers.isEmpty
                      ? null
                      : () => _submit(context),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save sale'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final amount = double.tryParse(_amountController.text) ?? 0;
      final draft = SaleDraft(
        customerId: _customerId!,
        title: _titleController.text.trim(),
        dealValue: amount,
        saleDate: _saleDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      await ref.read(trackerNotifierProvider.notifier).createSale(draft);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      showSuccessToast(context, 'Sale added.');
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, 'Failed to save: $error');
    } finally {
      if (context.mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
