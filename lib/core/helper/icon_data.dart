import 'package:flutter/material.dart';

IconData getIcon(String name) {
  switch (name) {
    case "school":
      return Icons.school;
    case "edit":
      return Icons.edit;
    case "calculate":
      return Icons.calculate;
    case "receipt":
      return Icons.receipt;
    case "public":
      return Icons.public;
    case "newspaper":
      return Icons.newspaper;
    case "warning":
      return Icons.warning;
    default:
      return Icons.category;
  }
}
