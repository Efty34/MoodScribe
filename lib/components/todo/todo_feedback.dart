import 'package:diary/utils/app_snackbar.dart';
import 'package:flutter/material.dart';

class TodoFeedback {
  static void showSuccessMessage(BuildContext context, String message) {
    AppSnackBar.show(
      context: context,
      message: message,
      type: SnackBarType.success,
      duration: const Duration(seconds: 2),
    );
  }

  static void showErrorMessage(BuildContext context, String message) {
    AppSnackBar.show(
      context: context,
      message: message,
      type: SnackBarType.error,
      duration: const Duration(seconds: 3),
    );
  }
}
