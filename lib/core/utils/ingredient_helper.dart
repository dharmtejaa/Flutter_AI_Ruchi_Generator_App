import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IngredientHelper {
  /// Add ingredient from text input
  /// Returns true if ingredient was added successfully
  static bool addIngredientFromText(
    BuildContext context,
    String text, {
    VoidCallback? onSuccess,
  }) {
    final provider = context.read<IngredientsProvider>();
    final trimmedText = text.trim();

    if (!provider.parseAndAddIngredient(trimmedText)) {
      CustomSnackBar.showWarning(
        context,
        'Please enter an ingredient name',
      );
      return false;
    }

    onSuccess?.call();
    return true;
  }
}

