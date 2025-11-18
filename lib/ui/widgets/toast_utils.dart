import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showSuccessToast(BuildContext context, String message) {
  toastification.show(
    context: context,
    type: ToastificationType.success,
    autoCloseDuration: const Duration(seconds: 3),
    style: ToastificationStyle.minimal,
    title: Text(message),
    alignment: Alignment.topRight,
  );
}

void showErrorToast(BuildContext context, String message) {
  toastification.show(
    context: context,
    type: ToastificationType.error,
    autoCloseDuration: const Duration(seconds: 4),
    style: ToastificationStyle.fillColored,
    title: Text(message),
    alignment: Alignment.topRight,
  );
}
