import 'package:flutter/material.dart';

class RouteFormProvider with ChangeNotifier {
  final routeNameCtrl = TextEditingController();

  int updateId = 0;
  bool forUpdate = false;

  void clearAll() {
    routeNameCtrl.clear();
    forUpdate = false;
    updateId = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    routeNameCtrl.dispose();
    super.dispose();
  }
}
