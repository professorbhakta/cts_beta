import 'package:flutter/material.dart';

class CommuterFormProvider with ChangeNotifier {
  // Personal Info form fields
  final commName = TextEditingController();
  final commMob = TextEditingController();
  final commEmail = TextEditingController();
  final commPass = TextEditingController();
  // final commAddr = TextEditingController();
  final commClg = TextEditingController();

  // Foreign Key IDs for dropdowns or selection
  int? selectedCabId;
  int? selectedPopId;
  int? selectedBatchId;

  // Flag to indicate if the form is for updating an existing commuter
  bool forUpdate = false;
  int updateId = 0;

  // Method to clear all form fields and selections
  void clearAll() {
    commName.clear();
    commMob.clear();
    commEmail.clear();
    commPass.clear();
    // commAddr.clear();
    commClg.clear();
    selectedCabId = null;
    selectedPopId = null;
    selectedBatchId = null;
    forUpdate = false;
    updateId = 0;
    notifyListeners();
  }

  // Dispose all controllers to prevent memory leaks
  @override
  void dispose() {
    commName.dispose();
    commMob.dispose();
    commEmail.dispose();
    commPass.dispose();
    // commAddr.dispose();
    commClg.dispose();
    super.dispose();
  }
}
