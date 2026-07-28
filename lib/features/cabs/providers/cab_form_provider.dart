import 'package:flutter/material.dart';

class CabFormProvider with ChangeNotifier {
  final regNumberCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();
  final kmCtrl = TextEditingController();
  int? selectedRouteId;

  int updateId = 0;
  bool forUpdate = false;

  void clearAll() {
    regNumberCtrl.clear();
    capacityCtrl.clear();
    kmCtrl.clear();
    selectedRouteId = null;
    forUpdate = false;
    updateId = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    regNumberCtrl.dispose();
    capacityCtrl.dispose();
    kmCtrl.dispose();
    super.dispose();
  }
}
