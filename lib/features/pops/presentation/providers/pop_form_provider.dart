import 'package:flutter/material.dart';

class PopFormProvider with ChangeNotifier {
  final nameCtrl = TextEditingController();
  final inLine = TextEditingController();
  int? selectedRouteId;

  int updateId = 0;
  bool forUpdate = false;

  void clearAll() {
    nameCtrl.clear();
    inLine.clear();
    selectedRouteId = null;
    forUpdate = false;
    updateId = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    inLine.dispose();
    super.dispose();
  }
}
